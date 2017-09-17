
# I create REPO_DIRPATH so that when I refer to a file, I am not referring
# to a file path that depends on the Process's current working directory
# but instead to a fixed, known path
REPO_DIRPATH = File.join(
  File.dirname(File.dirname(__FILE__)),
  'notification-examples-ios10'
)

# A convenience class that provides info about the Notif10Swift Xcode project
class Notif10Swift
  def self.entitlements_filepath
    File.join(
      REPO_DIRPATH,
      'notif10swift/notif10swift/notif10swift.entitlements'
    )
  end

  def self.project_filepath
    File.join(REPO_DIRPATH, 'notif10swift/notif10swift.xcodeproj')
  end

  def self.worskspace_filepath
    File.join(REPO_DIRPATH, 'notif10swift/notif10swift.xcworkspace')
  end

  def self.targetname
    'notif10swift'
  end

  def self.notification_service_targetname
    'NotificationService'
  end
end
