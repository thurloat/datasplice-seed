fs = require 'fs'
_ = require 'lodash'
gulp = require 'gulp'
http = require 'http'
path = require 'path'
When = require 'when'
lr = require 'tiny-lr'
childProcess = require 'child_process'
open = require 'gulp-open'
sass = require 'gulp-sass'
connect = require 'connect'
es = require 'event-stream'
gutil = require 'gulp-util'
clean = require 'gulp-clean'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'
rename = require 'gulp-rename'
embedlr = require 'gulp-embedlr'
refresh = require 'gulp-livereload'
minifycss = require 'gulp-minify-css'
webpack = require 'webpack'
plumber = require 'gulp-plumber'
server = do lr

{ red, cyan, blue, green } = gutil.colors

projectPath = "#{path.resolve __dirname}"
appPath     = "#{projectPath}/app"
buildPath   = "#{projectPath}/build"
distPath    = "#{projectPath}/dist"

cordovaPath     = "#{buildPath}/cordova"
jsBuildPath     = "#{buildPath}/js"
webBuildPath    = "#{buildPath}/web"
testBuildPath   = "#{buildPath}/test"
chromeBuildPath = "#{buildPath}/chrome"

webDistPath       = "#{distPath}/web"
chromeDistPath    = "#{distPath}/chrome"
chromePackageName = 'datasplice-seed.crx'
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

# TODO:externalize this to a config file
defaultChromeLocation = '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'

webpackConfig =
  cache: true
  entry:
    shared: "#{jsBuildPath}/shared.js"
    index: "#{jsBuildPath}/index.js"
    test: "#{jsBuildPath}/test.js"
  output:
    path: "#{webBuildPath}/src"
    filename: '[name].js'
  plugins: [
    new webpack.optimize.CommonsChunkPlugin 'lib.js', null, 2
    # expose common libraries globally so they don't have to be required
    new webpack.ProvidePlugin
      _: 'lodash'
      async: 'async'
      React: 'react'
      When: 'when'
  ]
  externals:
    # ignore a warning from When.js
    vertx: 'vertx'

if gutil.env.production
  # even though we have source maps, the uglify plug-in slows the build
  # down considerable so only use it with production flag
  webpackConfig.plugins.push new webpack.optimize.UglifyJsPlugin
else
  webpackConfig.devtool = 'sourcemap'
  webpackConfig.debug = true

# create a single webpack compiler to allow caching
webpackCompiler = webpack webpackConfig

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
    .pipe plumber()
    .pipe coffee bare: true
    .pipe gulp.dest "#{jsBuildPath}"

# Copies images to dest then reloads the page
gulp.task 'app:images', ->
  gulp.src "#{appPath}/images/**/*"
    .pipe gulp.dest "#{webBuildPath}/images"
    .pipe refresh server

# webpack works best if we compile everything at once instead of splitting
# into app and test script tasks
gulp.task 'all:scripts', ['coffee'], (cb) ->
  webpackCompiler.run (err, stats) ->
    gutil.log '[all:scripts]', stats.toString colors: true

    # trigger livereload manually
    server.changed
      body:
        files: [ 'index.html', 'test.html' ]

    cb err

gulp.task 'test:styles', ->
  gulp.src "node_modules/mocha/mocha.css"
    .pipe gulp.dest "#{testBuildPath}/styles"
    .pipe refresh server

# Compiles Sass files into css file
# and reloads the styles
gulp.task 'app:styles', ->
  es.concat(
    gulp.src "#{appPath}/styles/index.scss"
      # TODO: should include pattern for styles from React components
      .pipe sass errLogToConsole: true, includePaths: ['styles/includes']
    , gulp.src "bower_components/normalize-css/normalize.css"
  )
  .pipe rename 'index.css'
  .pipe if gutil.env.production then minifycss() else gutil.noop()
  .pipe gulp.dest "#{webBuildPath}/styles"
  .pipe refresh server

# Copy the HTML to web
gulp.task 'app:html', ->
  gulp.src "#{appPath}/index.html"
    # embeds the live reload script
    .pipe if gutil.env.production then gutil.noop() else embedlr port: lrPort
    .pipe gulp.dest "#{webBuildPath}"
    .pipe refresh server

# Copy the HTML to mocha
gulp.task 'test:html', ->
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
  gulp.watch "#{appPath}/images/**", ['app:images']
  gulp.watch "#{appPath}/src/**", ['all:scripts']
  gulp.watch "#{appPath}/src/**/*.scss", ['app:styles']
  gulp.watch "#{appPath}/styles/**", ['app:styles']
  gulp.watch "#{appPath}/index.html", ['app:html']
  gulp.watch "#{appPath}/test.html", ['test:html']

# Opens the app in your browser
gulp.task 'browse', ->
  options = url: "http://localhost:#{port}"
  gulp.src "#{webBuildPath}/index.html"
    .pipe open '', options

gulp.task 'clean', ['clean:build', 'clean:dist']

gulp.task 'clean:build', ->
  gulp.src ["#{buildPath}"], read: false
    .pipe clean force: true

gulp.task 'clean:dist', ->
  gulp.src ["#{distPath}"], read: false
    .pipe clean force: true

gulp.task 'build', [
  'build:web'
  'build:test'
  'build:chrome'
  'build:cordova'
]

gulp.task 'build:web', [
  'build:vendor'
  'app:html'
  'app:images'
  'app:styles'
  'all:scripts'
]

gulp.task 'build:test', [
  'test:html'
  'test:styles'
  'all:scripts'
]

# Grabs assets from vendors and puts in build/web/vendor
gulp.task 'build:vendor', ->
  for vendor in vendorAssets
    for asset in vendor.assets
      src = "#{vendor.base}/#{asset.src}"
      # some assets assume a particular path in the file structure
      dest = if asset.shared
        "#{webBuildPath}/#{asset.dest}"
      else
        "#{webBuildPath}/vendor/#{vendor.name}/#{asset.dest}"
      gulp.src src
        .pipe gulp.dest dest

# Copy the chromeapp manifests to build
gulp.task 'build:chrome', ['build:web'], (finishedTask) ->
  gulp.src [
    "#{webBuildPath}/**/*"
    'chromeapp.js'
    'manifest.json'
    'manifest.mobile.json'
  ]
    .pipe gulp.dest "#{chromeBuildPath}"
  finishedTask()

gulp.task 'build:android', ['build:cordova']
gulp.task 'build:ios', ['build:cordova']

gulp.task 'build:cordova', ['build:chrome'], (finishedTask) ->
  # Path exists is harmless. Use this to avoid scary log output
  pathExistsPattern = /Path already exists/g
  createCordova = ->
    deferred = When.defer()
    cmd = 'cca create cordova --link-to=chrome'
    childProcess.exec cmd, cwd: buildPath, (error, stdout, stderr) ->
      gutil.log cyan stdout
      if error
        if error.toString().match pathExistsPattern
          gutil.log cyan 'Cordova project already exists'
        else
          gutil.log red 'build:cordova: createCordova() failed'
          gutil.log red "\t#{error}"
        deferred.resolve error
      else
        deferred.resolve()
    deferred.promise
  prepareCordova = ->
    deferred = When.defer()
    cmd = 'cca prepare'
    childProcess.exec cmd, cwd: cordovaPath, (error, stdout, stderr) ->
      gutil.log cyan stdout
      if error
        if error.toString().match pathExistsPattern
          gutil.log cyan 'Cordova project already exists'
        else
          gutil.log red 'build:cordova: createCordova() failed'
          gutil.log red "\t#{error}"
        deferred.resolve error
      else
        deferred.resolve()
    deferred.promise

  When createCordova()
    .then (error) -> prepareCordova() unless error?
    .done -> finishedTask()

gulp.task 'dist', [
  'dist:web'
  'dist:chrome'
  'dist:android'
  'dist:ios'
]

gulp.task 'dist:web', ['build:web'], ->
  gulp.src "#{webBuildPath}/**/*"
    .pipe gulp.dest webDistPath

gulp.task 'dist:chrome', ['build:chrome'], (finishedTask) ->
  # Allow a different chrome location to be passed on the command line
  chrome = gutil.env.chrome or defaultChromeLocation
  cmd = "'#{chrome}' --pack-extension=build/chrome --pack-extension-key=chromeapp.pem"

  packageChrome = ->
    deferred = When.defer()
    childProcess.exec cmd, cwd: projectPath, (error, stdout, stderr) ->
      if error
        gutil.log red 'dist:chrome failed:'
        gutil.log red "\t#{stderr}"
        deferred.reject()
      else
        deferred.resolve()
    deferred.promise

  movePackage = ->
    src = "#{buildPath}/chrome.crx"
    dest = "#{chromeDistPath}"
    gulp.src src
      .pipe clean force: true
      .pipe rename chromePackageName
      .pipe gulp.dest chromeDistPath

  When packageChrome()
    .done ->
      movePackage()
      finishedTask()

gulp.task 'dist:android', ['build:cordova'], (finishedTask) ->
  childProcess.exec './build --release', cwd: "#{cordovaPath}/platforms/android/cordova", (error, stdout, stderr) ->
    if error
      gutil.log red 'dist:android failed:'
      gutil.log red "\t#{stderr}"
    else
      gulp.src "#{cordovaPath}/platforms/android/ant-build/*.apk"
        .pipe gulp.dest androidDistPath
    finishedTask()

gulp.task 'dist:ios', ['build:cordova'], ->
  gutil.log "\t#{blue 'TODO: build .ipa'}"

do (serverOpts = [
  'build:web'
  'build:test'
  'webserver'
  'livereload'
  'watch'
]) ->
  serverOpts.push 'browse' if gutil.env.open
  gulp.task 'run:web', serverOpts

gulp.task 'run:test', ['build:test'], ->
  gulp.src "#{jsBuildPath}/test.js", read: false
    .pipe mocha reporter: 'nyan'

gulp.task 'run:ios', ['build:cordova'], (finishedTask) ->
  cmd = "cca run ios #{if gutil.env.emulator then '--emulator' else ''}"
  childProcess.exec cmd, cwd: cordovaPath, (error, stdout, stderr) ->
    if error
      gutil.log red 'ios failed:'
      gutil.log red "\t#{stderr}"
    finishedTask()

gulp.task 'run:android', ['build:cordova'], (finishedTask) ->
  cmd = "cca run android #{if gutil.env.emulator then '--emulator' else ''}"
  childProcess.exec cmd, cwd: cordovaPath, (error, stdout, stderr) ->
    if error
      gutil.log red 'android failed:'
      gutil.log red "\t#{stderr}"
    finishedTask()

gulp.task 'run:chrome', ['dist:chrome'], (finishedTask) ->
  gutil.log "\t#{blue 'TODO'}"
  # # Allow a different chrome location to be passed on the command line
  # chrome = gutil.env.chrome or defaultChromeLocation
  # cmd = "'#{chrome}' #{chromeDistPath}/#{chromePackageName}"
  # gutil.log "Running #{blue cmd}"
  # childProcess.exec cmd, cwd: projectPath, (error, stdout, stderr) ->
  #   if error
  #     gutil.log red 'run:chrome failed:'
  #     gutil.log red "\t#{stderr}"

gulp.task 'default', ['build']

