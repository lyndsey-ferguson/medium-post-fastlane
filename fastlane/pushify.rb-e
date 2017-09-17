
require_relative 'notif10swift_info'
require 'pry-byebug'

# A class to manage all aspections Push for the Notif10Swift Xcode project
class Pushify
  # Entitlements methods
  #
  # general method to update various entitlements for the app
  def self.update_entitlements_file
    # the entitlements is just a plist with another name
    plist = Plist.parse_xml(Notif10Swift.entitlements_filepath)
    # _yield_ the plist to the block given to this method
    #   `update_entitlements_file`.
    yield plist
    plist.save_plist(Notif10Swift.entitlements_filepath)
  end

  # specific method to set or remove the push notification entitlement
  def self.update_push_entitlements(push_type)
    # calling the update_entitlements_file will _yield_ the plist to be
    #   operated on by the block `do |plist| ... end` and the resultant
    #   plist will be saved to the entitlements file
    update_entitlements_file do |plist|
      if %w[development production].include?(push_type)
        plist['aps-environment'] = push_type
      else
        plist.delete('aps-environment')
      end
    end
  end

  # Project Capbability methods
  #
  # general method to update various app capabilties in the Xcode project file
  #   to get the capabilities, one has to dig a little bit as demonstrated by
  #   this method.
  def self.update_app_capabilities
    project = Xcodeproj::Project.open(Notif10Swift.project_filepath)
    # following indentation pacifies Robucop, Ruby Style Linter without adding
    #   exceptions to the rules.
    target = project
             .native_targets
             .find { |s| s.name == Notif10Swift.targetname }

    target_attributes = project
                        .root_object
                        .attributes['TargetAttributes'][target.uuid]

    capabilities = target_attributes['SystemCapabilities']
    yield(capabilities)
    project.save
  end

  # specific method to enable or disable Push Capability for the Xcode project
  def self.enable_push_capability(enabled)
    update_app_capabilities do |capabilities|
      capabilities['com.apple.Push']['enabled'] = enabled ? '1' : '0'
    end
  end

  # Target Dependency methods
  #
  # general method to update the dependency relationship that the app target
  #   has on the notification service target.
  def self.update_notification_service_dependency
    project = Xcodeproj::Project.open(Notif10Swift.project_filepath)
    targets = project.native_targets
    target = targets.find { |s| s.name == Notif10Swift.targetname }
    notification_service_target = targets.find do |s|
      s.name == Notif10Swift.notification_service_targetname
    end
    yield(target, notification_service_target)
    project.save
  end

  # specific method to find the `Embed App Extensions` copy build phase in
  #   the app target
  def self.embed_app_extensions_buildphase(target)
    copy_buildphases = target.build_phases.select do |phase|
      phase.is_a?(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
    end
    copy_buildphases.find { |phase| phase.name == 'Embed App Extensions' }
  end

  # specific method to add the notification service target as a dependency
  #   for the app, and add the copy build phase to ensure that we package
  #   the notification service built product into the app bundle
  def self.add_notification_service_dependency(target, notification_target)
    target.add_dependency(notification_target)

    # get the notification_target's build product file reference so that
    #   we can add it to files that should be copied in the
    #   `Embed App Extensions` copy files build phase
    ns_product_reference = notification_target.product_reference
    embed_buildphase = embed_app_extensions_buildphase(target)
    embed_buildphase.add_file_reference(ns_product_reference, true)
  end

  # specific method to remove the notification service target from the
  #   dependencies that the app has, and to make sure that we do not
  #   try to copy the notification's built product into the app bundle
  #   as we will not be building it and do not want it.
  def self.remove_notification_service_dependency(target, notification_target)
    target.dependencies.reject! do |target_dependency|
      target_dependency.target == notification_target
    end

    # remove the notification service's built product from the
    #   `Embed App Extensions` copy files build phase.
    embed_buildphase = embed_app_extensions_buildphase(target)
    embed_buildphase.remove_file_reference(
      notification_target.product_reference
    )
  end

  # specific method to either add or remove target dependencies and the copy
  #   files build phase so that we either build and package the notification
  #   service extension or not.
  def self.update_push_target_dependencies(enabled)
    update_notification_service_dependency do |target, notification_target|
      if enabled
        add_notification_service_dependency(target, notification_target)
      else
        remove_notification_service_dependency(target, notification_target)
      end
    end
  end

  # main entry point for fastlane users. Enable or disable the various
  #  Xcode parts for Push Notifications
  def self.enable_push(push_type = 'none')
    update_push_entitlements(push_type)
    enabled = %w[development production].include?(push_type)
    enable_push_capability(enabled)
    update_push_target_dependencies(enabled)
  end
end
