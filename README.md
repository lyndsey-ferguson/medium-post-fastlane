# medium-post-fastlane

## Description

Example code which is a companion to the Medium article, [Extremely customized iOS app builds with fastlane and Ruby](https://medium.com/@lyndseydf/extremely-customized-ios-app-builds-using-fastlane-and-ruby-cf123622f2d3), that describes a build system that:
- simplifies the handling of different options
- supports complex project editing
- is under unit tests using Rspec

## Setting up

Clone this repo and run the following commands from within the clone:
```
  git submodule init
  git submodule update
```

Get the Gems you need:
```
  gem install bundler
  bundle install
```

Run the sample code from the Terminal in this cloned repo:
```
  echo "set the push notification production instead of the default development"
  bundle exec fastlane build push_type:production
```
```
  echo "remove the push notification entirely from the project"
  bundle exec fastlane build
```

## Review

When you run `fastlane` from the top level directory from the command line in the Terminal, it looks for a `Fastfile` in the `fastlane` directory.

There, it looks for the _lane_ you requested. Think of `fastlane` as a road that allows you to arrive at a destination.

In the above examples, we are telling `fastlane` to take the `build` lane so that we get a built product quickly. However, as part of that drive, we have to take a small detour on a different lane, to enable or disable push notifications.

We could also just call `fastlane` and tell it to use the
`enable_push` lane directly if we only wanted the project to be set up with push enabled. This could be useful if we had a more complex lane that would set up our project in a special way.

_If you have not set a provisioning profile for the notification swift project, the `fastlane` `gym` action will fail. Feel free to comment it out by prepending `#` to it: `# gym(workspace: Notif10Swift.worskspace_filepath)`_

Start by reviewing the `fastlane/Fastfile` file. See how the lanes are declared. You'll see that the `pushify` Ruby file is included, and that is where the `Pushify` class comes from.

In `pushify`, there are methods that demonstrate how to edit entitlements files, how to edit the Project Capabilities such as Push and iCloud, and how to edit Target dependencies and Copy Files Build Phases.

`Pushify` uses convenience methods in the `notif10swift_info` file to figure out the various pre-set aspects of the `notif10swift` project.
