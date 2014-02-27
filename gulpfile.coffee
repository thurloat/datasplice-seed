fs = require 'fs'
_ = require 'lodash'
gulp = require 'gulp'
http = require 'http'
path = require 'path'
When = require 'when'
lr = require 'tiny-lr'
childProcess = (require 'child_process')
open = require 'gulp-open'
sass = require 'gulp-sass'
connect = require 'connect'
es = require 'event-stream'
gutil = require 'gulp-util'
clean = require 'gulp-clean'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
embedlr = require 'gulp-embedlr'
refresh = require 'gulp-livereload'
minifycss = require 'gulp-minify-css'
browserify = require 'gulp-browserify'
server = do lr

red = gutil.colors.red
cyan = gutil.colors.cyan
blue = gutil.colors.blue
green = gutil.colors.green

projectPath   = "#{path.resolve __dirname}"
appPath       = "#{projectPath}/app"
buildPath     = "#{projectPath}/build"
distPath      = "#{projectPath}/dist"
cordovaPath   = "#{projectPath}/cordova"

jsBuildPath      = "#{buildPath}/js"
webBuildPath     = "#{buildPath}/web"
testBuildPath    = "#{buildPath}/test"
chromeBuildPath  = "#{buildPath}/chrome"

webDistPath       = "#{distPath}/web"
chromeDistPath    = "#{distPath}/chrome"
androidDistPath   = "#{distPath}/android"
iosDistPath       = "#{distPath}/ios"

nodeModulesPath     = "#{projectPath}/node_modules"
bowerComponentsPath = "#{projectPath}/bower_components"

vendorAssets = [
  {
    name: 'glyphicons'
    base: './bower_components/bootstrap-sass/fonts'
    assets: [
      { src: '*.*', dest: 'fonts', shared: true }
    ]
  }
]

port = 3000
# allow to connect from anywhere
hostname = null
# change this to something unique if you want to run multiple projects
# side-by-side
lrPort = gutil.env.lrport or 35729

browserifyOptions =
  debug: not gutil.env.production

# Starts the webserver
gulp.task 'webserver', ->
  application = connect()
    # allows import of npm/bower resources
    .use connect.static nodeModulesPath
    .use connect.static bowerComponentsPath
    # Mount the mocha tests
    .use connect.static testBuildPath
    # Mount the app
    .use connect.static webBuildPath
    .use connect.directory webBuildPath
  (http.createServer application).listen port, hostname

gulp.task 'coffee', ->
  gulp.src "#{appPath}/src/**/*.coffee"
    .pipe coffee bare: true
    .pipe gulp.dest "#{jsBuildPath}"

# Copies images to dest then reloads the page
gulp.task 'images', ->
  gulp.src "#{appPath}/images/**/*"
    .pipe gulp.dest "#{webBuildPath}/images"
    .pipe refresh server

gulp.task 'scripts', ['coffee'], ->
  gulp.src "#{jsBuildPath}/index.js", read: false
    .pipe browserify browserifyOptions
    .on 'error', gutil.log
    .pipe rename 'index.js'
    .pipe if gutil.env.production then uglify() else gutil.noop()
    .pipe gulp.dest "#{webBuildPath}/src"
    .pipe refresh server

gulp.task 'test-scripts', ['scripts'], ->
  gulp.src "#{jsBuildPath}/test.js", read: false
    .pipe browserify browserifyOptions
    .on 'error', gutil.log
    .pipe rename 'test.js'
    .pipe gulp.dest "#{testBuildPath}/src"
    .pipe refresh server

# Compiles Sass files into css file
# and reloads the styles
gulp.task 'test-styles', ->
  gulp.src "node_modules/mocha/mocha.css"
    .pipe gulp.dest "#{testBuildPath}/styles"
    .pipe refresh server

# Compiles Sass files into css file
# and reloads the styles
gulp.task 'styles', ->
  es.concat(
    gulp.src "#{appPath}/styles/index.scss"
      # TODO: should include pattern for styles from React components
      .pipe sass includePaths: ['styles/includes']
      .on 'error', gutil.log
    , gulp.src "bower_components/normalize-css/normalize.css"
  )
  .pipe rename 'index.css'
  .pipe if gutil.env.production then minifycss() else gutil.noop()
  .pipe gulp.dest "#{webBuildPath}/styles"
  .pipe refresh server

# Copy the HTML to web
gulp.task 'html', ->
  gulp.src "#{appPath}/index.html"
    # embeds the live reload script
    .pipe if gutil.env.production then gutil.noop() else embedlr port: lrPort
    .pipe gulp.dest "#{webBuildPath}"
    .pipe refresh server

# Copy the HTML to mocha
gulp.task 'test-html', ->
  gulp.src "#{appPath}/test.html"
    # embeds the live reload script
    .pipe embedlr()
    .pipe gulp.dest "#{testBuildPath}"
    .pipe refresh server

gulp.task 'livereload', ->
  server.listen lrPort, (err) ->
    gutil.log err if err

# Watches files for changes
gulp.task 'watch', ->
  gulp.watch "#{appPath}/images/**", ['images']
  gulp.watch "#{appPath}/src/**", ['scripts', 'test-scripts']
  gulp.watch "#{appPath}/src/**/*.scss", ['styles']
  gulp.watch "#{appPath}/styles/**", ['styles']
  gulp.watch "#{appPath}/index.html", ['html']
  gulp.watch "#{appPath}/test.html", ['test-html']

# Opens the app in your browser
gulp.task 'browse', ->
  options = url: "http://localhost:#{port}"
  gulp.src "#{webBuildPath}/index.html"
    .pipe open '', options

gulp.task 'build-web', [
  'build-vendor'
  'html'
  'images'
  'styles'
  'scripts'
]

gulp.task 'build-test', [
  'test-html'
  'test-styles'
  'test-scripts'
]

# Grabs assets from vendors and puts in build/web/vendor
gulp.task 'build-vendor', ->
  for vendor in vendorAssets
    gutil.log "Building vendor #{cyan vendor.name}"
    for asset in vendor.assets
      src = "#{vendor.base}/#{asset.src}"
      # some assets assume a particular path in the file structure
      dest = if asset.shared
        "#{webBuildPath}/#{asset.dest}"
      else
        "#{webBuildPath}/vendor/#{vendor.name}/#{asset.dest}"
      gutil.log "\tcopying #{cyan src} to #{cyan dest}"
      gulp.src src
        .pipe gulp.dest dest

# Copy the chromeapp manifests to build
gulp.task 'build-chrome', ['build-web'], ->
  gulp.src [
    "#{webBuildPath}/**/*"
    'chromeapp.js'
    'manifest.json'
    'manifest.mobile.json'
  ]
    .pipe gulp.dest "#{chromeBuildPath}"

gulp.task 'build-cordova', ['build-chrome'], (finishedTask) ->
  gutil.log "Preparing #{blue 'cordova'}..."
  childProcess.exec 'cca prepare', cwd: cordovaPath, (error, stdout, stderr) ->
    gutil.log "#{blue stdout}"
    if error
      gutil.log red 'build-cordova failed:'
      gutil.log red "\t#{stderr}"
    finishedTask()

gulp.task 'dist-web', ['build-web'], ->
  gulp.src "#{webBuildPath}/**/*"
    .pipe gulp.dest webDistPath

gulp.task 'dist-chrome', ['build-chrome'], (finishedTask) ->
  gutil.log 'TODO'
  # cmd = "crx pack #{chromeBuildPath} -f '#{distPath}/DataSpliceSeedChromeApp.crx -p chromeapp.pem"
  # childProcess.exec cmd, cwd: projectPath, (error, stdout, stderr) ->
  #   gutil.log "#{blue stdout}"
  #   if error
  #     gutil.log red 'dist-chrome failed:'
  #     gutil.log red "\t#{stderr}"
  #   finishedTask()
  finishedTask()

gulp.task 'dist-android', ['build-cordova'], (finishedTask) ->
  childProcess.exec './build --release', cwd: "#{cordovaPath}/platforms/android/cordova", (error, stdout, stderr) ->
    gutil.log "#{green stdout}"
    if error
      gutil.log red 'dist-android failed:'
      gutil.log red "\t#{stderr}"
    else
      gulp.src "#{cordovaPath}/platforms/android/ant-build/*.apk"
        .pipe gulp.dest androidDistPath
    finishedTask()

gulp.task 'dist-ios', ['build-cordova'], ->
  gutil.log 'TODO: build .ipa'

do (serverOpts = ['build', 'webserver', 'livereload', 'watch']) ->
  serverOpts.push 'browse' if gutil.env.open
  gulp.task 'web', serverOpts

gulp.task 'ios', ['build-cordova'], (finishedTask) ->
  cmd = "cca run ios #{if gutil.env.emulator then '--emulator' else ''}"
  childProcess.exec cmd, cwd: cordovaPath, (error, stdout, stderr) ->
    gutil.log "blue stdout"
    if error
      gutil.log red 'ios failed:'
      gutil.log red "\t#{stderr}"
    finishedTask()

gulp.task 'android', ['build-cordova'], (finishedTask) ->
  cmd = "cca run android #{if gutil.env.emulator then '--emulator' else ''}"
  childProcess.exec cmd, cwd: cordovaPath, (error, stdout, stderr) ->
    gutil.log "green stdout"
    if error
      gutil.log red 'android failed:'
      gutil.log red "\t#{stderr}"
    finishedTask()

gulp.task 'clean', ->
  gulp.src ["#{buildPath}"], read: false
    .pipe clean force: true

gulp.task 'test', ['coffee'], ->
  gulp.src "#{jsBuildPath}/test.js", read: false
    .pipe browserify browserifyOptions
    .on 'error', gutil.log
    .pipe mocha reporter: 'nyan'
    .on 'error', gutil.log

gulp.task 'build', [
  'build-web'
  'build-test'
  'build-chrome'
  'build-cordova'
]

gulp.task 'dist', [
  'dist-web'
  'dist-chrome'
  'dist-android'
  'dist-ios'
]

gulp.task 'default', ['build']
