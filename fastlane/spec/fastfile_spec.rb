describe Fastlane do
  describe Fastlane::FastFile do
    describe 'GIVEN a call to the lane :build' do
      before(:all) do
        @fastfile = Fastlane::FastFile.new('fastlane/Fastfile')
        @runner = @fastfile.runner
      end

      before(:each) do
        # we stub out Pushify's :enable_push method so we don't actually
        #   change project files
        allow(Pushify).to receive(:enable_push)
      end

      after(:each) do
        # we return the :enable_push method in case we want to test its
        #   internals
        allow(Pushify).to receive(:enable_push).and_call_original
      end

      describe 'WHEN called with no parameters' do
        it 'THEN it executes the correct actions' do
          # each fastlane action is a class with the method :run
          #   this allows us to expect that it is called without actually
          #   calling it.
          expect(Fastlane::Actions::GymAction).to receive(:run)
          @runner.execute(:build, :ios)
        end
        it 'THEN it calls Pushify with the correct value' do
          expect(Pushify).to receive(:enable_push).with('none')
          # stubbing out Gym's run as we want to isolate the expectations for this
          #   test
          allow(Fastlane::Actions::GymAction).to receive(:run)
          @runner.execute(:build, :ios)
        end
      end

      describe 'WHEN called with a push_type option' do
        it 'THEN it executes the correct actions' do
          expect(Fastlane::Actions::GymAction).to receive(:run)
          # from the command line, one would type:
          #   fastlane build push_type:development
          #   from this test, we pass it to fastlane's runner as a Ruby Hash
          @runner.execute(:build, :ios, { push_type: 'development' })
        end
        it 'THEN it calls Pushify with the correct value' do
          expect(Pushify).to receive(:enable_push).with('development')
          allow(Fastlane::Actions::GymAction).to receive(:run)
          @runner.execute(:build, :ios, { push_type: 'development' })
        end
      end
    end
  end
end
