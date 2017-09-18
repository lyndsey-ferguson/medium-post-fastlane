require_relative '../pushify'

# Configure RSpec to allow us to make tests that share 'context'
RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to
  # set it on RSpec 3.
  #
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

# A shared context that allows our editing of the notification service target
#   dependencies to be tested without needing real Xcodeproj classes. RSpec
#   is amazing!!
RSpec.shared_context "edit notification service dependencies", shared_context: :metadata do
  before(:each) do
    # OpenStruct allows us to add instance variables freely
    @notification_service_target = OpenStruct.new
    @notification_service_target.product_reference = OpenStruct.new
    @ns_product_reference = OpenStruct.new
    @notification_service_target.product_reference = @ns_product_reference

    # mock out the methods for the build phase so that Pushify can call it
    #   without crashing and at the same time allowing us to 'expect' the calls
    @embed_app_extensions_buildphase = OpenStruct.new
    allow(@embed_app_extensions_buildphase)
      .to receive(:add_file_reference)
    allow(@embed_app_extensions_buildphase)
      .to receive(:remove_file_reference)

    @target = OpenStruct.new
    @notification_service_target_dependency = OpenStruct.new
    @notification_service_target_dependency.target = @notification_service_target

    dummy_target_dependency = OpenStruct.new
    dummy_target_dependency.target = OpenStruct.new

    # make sure that our target has the dependencies so we can check that it
    #   is removed appropriately
    @target.dependencies = [dummy_target_dependency, @notification_service_target_dependency]
    allow(@target)
      .to receive(:add_dependency)
      .with(@notification_service_target)

    # a convenience method to return our tracked build phase
    allow(Pushify)
      .to receive(:embed_app_extensions_buildphase)
      .and_return(@embed_app_extensions_buildphase)
  end

  after(:each) do
    # reset Pushify to use the real method when we're done
    allow(Pushify)
      .to receive(:embed_app_extensions_buildphase)
      .and_call_original
  end
end

describe Pushify do
  describe 'GIVEN a call to update_push_entitlements' do
    before(:each) do
      @entitlements = { 'aps-environment' => '' }
      allow(Pushify).to receive(:update_entitlements_file).and_yield(@entitlements)
    end

    after(:each) do
      allow(Pushify).to receive(:update_entitlements_file).and_call_original
    end

    describe 'WHEN the push_type is "development"' do
      it 'THEN the entitlements file aps-environment is "development"' do
        Pushify.update_push_entitlements('development')
        expect(@entitlements['aps-environment']).to eq('development')
      end
    end

    describe 'WHEN the push_type is "production"' do
      it 'THEN the entitlements file aps-environment is "production"' do
        Pushify.update_push_entitlements('production')
        expect(@entitlements['aps-environment']).to eq('production')
      end
    end

    describe 'WHEN the push_type is "none"' do
      it 'THEN the entitlements file aps-environment is removed' do
        Pushify.update_push_entitlements('none')
        expect(@entitlements).not_to have_key('aps-environment')
      end
    end

    describe 'WHEN the push_type is nil' do
      it 'THEN the entitlements file aps-environment is removed' do
        Pushify.update_push_entitlements(nil)
        expect(@entitlements).not_to have_key('aps-environment')
      end
    end
  end

  describe 'GIVEN a call to update_app_capabilities' do
    before(:each) do
      @capabilities = {
        'com.apple.Push' => {
          'enabled' => ''
        }
      }
      allow(Pushify).to receive(:update_app_capabilities).and_yield(@capabilities)
    end

    after(:each) do
      allow(Pushify).to receive(:update_app_capabilities).and_call_original
    end

    describe 'WHEN push is enabled' do
      it 'THEN the push capability is 1' do
        Pushify.enable_push_capability(true)
        expect(@capabilities['com.apple.Push']['enabled']).to eq('1')
      end
    end

    describe 'WHEN push is disabled' do
      it 'THEN the push capability is 0' do
        Pushify.enable_push_capability(false)
        expect(@capabilities['com.apple.Push']['enabled']).to eq('0')
      end
    end
  end

  describe 'GIVEN a call to add_notification_service_dependency' do
    include_context "edit notification service dependencies"

    it 'THEN the target depends on the notification service target' do
      expect(@target)
        .to receive(:add_dependency)
        .with(@notification_service_target)

      Pushify.add_notification_service_dependency(
        @target,
        @notification_service_target
      )
    end

    it 'THEN the target\'s embed app extensions build phase has notification service\'s built product' do
      expect(@embed_app_extensions_buildphase)
        .to receive(:add_file_reference)
        .with(@ns_product_reference, true)

      Pushify.add_notification_service_dependency(
        @target,
        @notification_service_target
      )
    end
  end

  describe 'GIVEN a call to remove_notification_service_dependency' do
    include_context "edit notification service dependencies"

    it 'THEN the target does not depend on the notification service target' do
      Pushify.remove_notification_service_dependency(
        @target,
        @notification_service_target
      )
      expect(@target.dependencies).not_to include(@notification_service_target_dependency)
    end

    it 'THEN the target\'s embed app extensions build phase does not have the notification service\'s built product' do
      expect(@embed_app_extensions_buildphase)
        .to receive(:remove_file_reference)
        .with(@notification_service_target.product_reference)

      Pushify.remove_notification_service_dependency(
        @target,
        @notification_service_target
      )
    end
  end

  describe 'GIVEN a call to update_push_target_dependencies' do
    before(:each) do
      @target = OpenStruct.new
      @notification_service_target = OpenStruct.new

      allow(Pushify)
        .to receive(:update_notification_service_dependency)
        .and_yield(@target, @notification_service_target)
    end

    after(:each) do
      allow(Pushify)
        .to receive(:update_notification_service_dependency)
        .and_call_original
    end

    describe 'WHEN push is enabled' do
      it 'THEN add_notification_service_dependency is called' do
        expect(Pushify)
          .to receive(:add_notification_service_dependency)
          .with(@target, @notification_service_target)
        Pushify.update_push_target_dependencies(true)
      end

      it 'THEN remove_notification_service_dependency is called' do
        expect(Pushify)
          .to receive(:remove_notification_service_dependency)
          .with(@target, @notification_service_target)

        Pushify.update_push_target_dependencies(false)
      end
    end
  end

  describe 'GIVEN a call to enable_push' do
    describe 'WHEN push_type is "production"' do
      it 'THEN the correct methods are called with the correct value' do
        expect(Pushify).to receive(:update_push_entitlements).with('production')
        expect(Pushify).to receive(:enable_push_capability).with(true)
        expect(Pushify).to receive(:update_push_target_dependencies).with(true)
        Pushify.enable_push('production')
      end
    end

    describe 'WHEN push_type is "development"' do
      it 'THEN the correct methods are called with the correct value' do
        expect(Pushify).to receive(:update_push_entitlements).with('development')
        expect(Pushify).to receive(:enable_push_capability).with(true)
        expect(Pushify).to receive(:update_push_target_dependencies).with(true)
        Pushify.enable_push('development')
      end
    end

    describe 'WHEN push_type is "none"' do
      it 'THEN the correct methods are called with the correct value' do
        expect(Pushify).to receive(:update_push_entitlements).with('none')
        expect(Pushify).to receive(:enable_push_capability).with(false)
        expect(Pushify).to receive(:update_push_target_dependencies).with(false)
        Pushify.enable_push('none')
      end
    end

    describe 'WHEN push_type is not given' do
      it 'THEN the correct methods are called with the correct value' do
        expect(Pushify).to receive(:update_push_entitlements).with('none')
        expect(Pushify).to receive(:enable_push_capability).with(false)
        expect(Pushify).to receive(:update_push_target_dependencies).with(false)
        Pushify.enable_push
      end
    end
  end
end
