DataSplice seed builds to:

- `build/js` unminified js
- `build/web` standard webapp
- `build/test` mocha tests in the browser
- `build/chrome` chrome app
- `build/cordova` chrome app packaged as a cordova app

Build tasks:

- `gulp clean` deletes the build dir
- `gulp` builds everything
- `gulp build-web` creates build/js, build/web, and build/test
- `gulp build-chrome` creates a chrome app in build/chrome
- `gulp build-cordova` converts the chrome app into a cordova app in build/cordova

Run tasks:

- `gulp run-web` runs the web/test server on port 3000
- `gulp run-ios` runs the ios emulator
- `gulp run-android` runs the android emulator

To run the chrome app go to chrome://extensions and load `build/chrome` as an unpacked extension:

![Chrome unpacked extension](http://i.imgur.com/IkZWOLV.png "Chrome unpacked extension")

Uses [MobileChromeApps](https://github.com/MobileChromeApps/mobile-chrome-apps) to convert the chrome app into a cordova app as introduced on [this Chromium Team blog post](http://blog.chromium.org/2014/01/run-chrome-apps-on-mobile-using-apache.html). This (in theory) gives us the potential to code to the Chrome App API and have that API translate over to Cordova for us. The status of the API can be found here:

- [MobileChromeApps API Status](https://github.com/MobileChromeApps/mobile-chrome-apps/blob/master/docs/APIStatus.md)

