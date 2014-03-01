DataSplice Seed
===
DataSplice Seed is a sample cross-platform web application that supports packaging as:

- Standard webapp
- [Chrome app](https://developer.chrome.com/apps/about_apps)
- Android app
- iOS app

It is built with the following technologies:

- App: [ReactJS](facebook.github.io/react/) / [SASS](sass-lang.com) / [When](https://github.com/cujojs/when)
- Tests: [Mocha](visionmedia.github.io/mocha/) / [Chai](chaijs.com) / [SinonJS](http://sinonjs.org/)
- Build: [GulpJS](gulpjs.com) / [Bower](bower.io) / [Browserify](browserify.org) / [Cordova](cordova.apache.org) / [MobileChromeApps](https://github.com/MobileChromeApps/mobile-chrome-apps)
 - Note: we'll likely move away from Browserify in favor of something like [Webpack](webpack.github.io)

### Build

DataSplice seed builds to:

- `build/js` unminified js
- `build/web` standard webapp
- `build/test` mocha tests in the browser
- `build/chrome` chrome app
- `cordova/www` is symlinked to `build/chrome`

Build tasks:

- `gulp clean` deletes `./build` and `./cordova/platforms`
- `gulp` builds everything
- `gulp web:build` creates `./build/js`, `./build/web`, and `./build/test`
- `gulp chrome:build` creates a chrome app in `./build/chrome`
- `gulp cordova:build` creates platforms (if not exists) and performs cordova perpare

Dist tasks:

- `gulp web:dist` package webapp into `./dist/web`
- __(TODO)__ `gulp chrome:dist` package chrome `.crx` file into `./dist/chrome`
- `gulp android:dist` package `.apk` into `./dist/android`
- __(TODO)__ `gulp ios:dist` package ios file into `./dist/ios`

Run tasks:

- `gulp test:run` runs mocha tests in console
- `gulp web:run` runs the web/test server on port 3000
- `gulp ios:run` `[--emulator]` runs the ios app
- `gulp android:run` `[--emulator]` runs the android

To run the chrome app go to chrome://extensions and load `build/chrome` as an unpacked extension:

![Chrome unpacked extension](http://i.imgur.com/IkZWOLV.png "Chrome unpacked extension")

Uses [MobileChromeApps](https://github.com/MobileChromeApps/mobile-chrome-apps) to convert the chrome app into a cordova app as introduced on [this Chromium Team blog post](http://blog.chromium.org/2014/01/run-chrome-apps-on-mobile-using-apache.html). This (in theory) gives us the potential to code to the Chrome App API and have that API translate over to Cordova for us. The status of the API can be found here:

- [MobileChromeApps API Status](https://github.com/MobileChromeApps/mobile-chrome-apps/blob/master/docs/APIStatus.md)

