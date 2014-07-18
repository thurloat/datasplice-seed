_             = require 'lodash'
childProcess  = require 'child_process'
connect       = require 'connect'
es            = require 'event-stream'
fs            = require 'fs'
gulp          = require 'gulp'
$             = do require 'gulp-load-plugins'
http          = require 'http'
path          = require 'path'
serveStatic   = require 'serve-static'
webpack       = require 'webpack'

{ Promise } = require 'es6-promise'

{ red, cyan, blue, green, magenta } = $.util.colors

projectPath       = "#{path.resolve __dirname}"
appPath           = "#{projectPath}/app"
buildPath         = "#{projectPath}/build"
distPath          = "#{projectPath}/dist"
nodeModulesPath   = "#{projectPath}/node_modules"

cordovaPath     = "#{buildPath}/cordova"
jsBuildPath     = "#{buildPath}/js"
webBuildPath    = "#{buildPath}/web"
testBuildPath   = "#{buildPath}/test"
chromeBuildPath = "#{buildPath}/chrome"

globalVendorsPath = "#{webBuildPath}/vendor"
globalVendorsFileName = 'global.js'

webDistPath       = "#{distPath}/web"
chromeDistPath    = "#{distPath}/chrome"
androidDistPath   = "#{distPath}/android"
iosDistPath       = "#{distPath}/ios"

chromePackageName = 'datasplice-seed.crx'

vendorAssets = [
  {
    name: 'font-awesome'
    base: "#{nodeModulesPath}/font-awesome/fonts"
    dest: "#{webBuildPath}/fonts"
    shared: true
    assets: [ '*.*' ]
  }
]

port = 3000
# allow to connect from anywhere
hostname = null
# change this to something unique if you want to run multiple projects
# side-by-side
lrPort = $.util.env.lrport or 35729

# TODO:externalize this to a config file
defaultChromeLocation = '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'

webpackConfig =
  cache: true
  devtool: 'source-map' unless $.util.env.nosourcemap
  debug: not $.util.env.production
  entry:
    # Unecessary. CommonsChunkPlugin will identify the shared stuff
    # shared: "#{appPath}/src/shared.coffee"
    index: "#{appPath}/src/index.coffee"
    test: "#{appPath}/src/test.coffee"
  output:
    path: "#{webBuildPath}/src"
    filename: '[name].js'
  resolve:
    extensions: [
      ''
      '.coffee'
      '.js'
    ]
  module:
    loaders: [
      # need to disable AMD loader with sinon. see:
      # https://github.com/webpack/webpack/issues/177
      test: /sinon\.js$/, loader: 'imports?define=>false'
    ,
      test:
        ///
        \.gif$
        |\.eot$
        |\.jpe?g$
        |\.mp3$
        |\.png$
        |\.svg$
        |\.ttf$
        |\.wav$
        |\.woff$
        ///
      loader: 'url-loader'
    ,
      test: /\.scss$/
      # For syntax of loader configuration see:
      #   https://github.com/webpack/loader-utils#parsequery
      loader: 'style-loader!css-loader!sass-loader?\
        includePaths[]=app/src,\
        includePaths[]=app/src/ui,\
        includePaths[]=app/src/ui/widgets,\
        includePaths[]=node_modules'
    ,
      test: /\.css$/
      loader: 'style-loader!css-loader'
    ,
      test: /\.coffee$/
      loader: 'coffee-loader'
    ]
  plugins: [
    new webpack.optimize.CommonsChunkPlugin 'lib.js', null, 2
    # expose common libraries globally so they don't have to be required
    new webpack.ProvidePlugin
      _: 'lodash'
      async: 'async'
      React: 'react'
  ]

# create a single webpack compiler to allow caching
webpackCompiler = webpack webpackConfig

# Starts the webserver
gulp.task 'webserver', ->
  application = connect()
    # allows import of npm resources
    .use serveStatic nodeModulesPath
    # Mount the mocha tests
    .use serveStatic testBuildPath
    # Mount the app
    .use serveStatic webBuildPath
  (http.createServer application).listen port, hostname

# Copies images to dest then reloads the page
gulp.task 'app:images', ->
  gulp.src "#{appPath}/images/**/*"
    .pipe gulp.dest "#{webBuildPath}/images"

# webpack works best if we compile everything at once instead of splitting
# into app and test script tasks
gulp.task 'app:src', (cb) ->
  webpackCompiler.run (err, stats) ->
    $.util.log '[app:src]', stats.toString colors: true

    cb err

gulp.task 'test:styles', ->
  gulp.src "node_modules/mocha/mocha.css"
    .pipe gulp.dest "#{testBuildPath}/styles"

# Compiles Sass files into css file
# and reloads the styles
gulp.task 'app:styles', ->
  gulp.src "#{appPath}/styles/index.scss"
    .pipe $.sass
      errLogToConsole: true
      includePaths: ['node_modules']
    .pipe if $.util.env.production then $.minifyCss() else $.util.noop()
    .pipe gulp.dest "#{webBuildPath}/styles"

# Copy the HTML to web
gulp.task 'app:html', ->
  gulp.src "#{appPath}/index.html"
    # embeds the live reload script
    .pipe if $.util.env.production
        $.util.noop()
      else
        $.embedlr port: lrPort
    .pipe gulp.dest "#{webBuildPath}"

# Copy the HTML to mocha
gulp.task 'test:html', ->
  gulp.src "#{appPath}/test.html"
    # embeds the live reload script
    .pipe $.embedlr()
    .pipe gulp.dest "#{testBuildPath}"

gulp.task 'livereload', ->
  $.livereload.changed()

# Watches files for changes
gulp.task 'watch', ->
  doReload = (task) ->
    -> $.runSequence task, 'livereload'

  gulp.watch "#{appPath}/images/**", doReload 'app:images'
  gulp.watch "#{appPath}/src/**/*.coffee", doReload 'app:src'
  gulp.watch "#{appPath}/src/**/*.scss", doReload 'app:styles'
  gulp.watch "#{appPath}/styles/**", doReload 'app:styles'
  gulp.watch "#{appPath}/index.html", doReload 'app:html'
  gulp.watch "#{appPath}/test.html", doReload 'test:html'

# Opens the app in your browser
gulp.task 'browse', ->
  options = url: "http://localhost:#{port}"
  gulp.src "#{webBuildPath}/index.html"
    .pipe open '', options

gulp.task 'clean', ['clean:build', 'clean:dist']

gulp.task 'clean:build', ->
  gulp.src ["#{buildPath}"], read: false
    .pipe $.rimraf force: true

gulp.task 'clean:dist', ->
  gulp.src ["#{distPath}"], read: false
    .pipe $.rimraf force: true

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
  'app:src'
]

gulp.task 'build:test', [
  'test:html'
  'test:styles'
  'app:src'
]

# Grabs assets from vendors and puts in build/web/vendor
gulp.task 'build:vendor', ->
  globalVendors = []
  for vendor in vendorAssets
    $.util.log cyan vendor.name

    # a little validation
    if (not vendor.dest? and not vendor.global) or
      (vendor.dest? and vendor.global)
        $.util.log red "#{vendor.name} error - you can have dest or global \
        but not both"
        return false

    # process each asset
    for asset in vendor.assets
      dest = "#{vendor.dest}/vendor/#{vendor.name}"

      if _.isString asset
        asset = src: "#{vendor.base}/#{asset}", dest: dest
      else if _.isObject asset
        asset.src = "#{vendor.base}/#{asset.src}"
        asset.dest = "#{dest}/#{if asset.dest? then asset.dest else ''}"

      if vendor.global or asset.global
        globalVendors.push asset.src
        $.util.log "\t#{asset.src} -> " +
          (magenta "#{globalVendorsPath}/#{globalVendorsFileName}")
      else
        asset.dest = vendor.dest if vendor.shared
        (gulp.src asset.src).pipe gulp.dest asset.dest
        $.util.log "\t#{asset.src} -> " + magenta "#{asset.dest}"

  # concat files to script if eligible
  # minify concatenated file if necessary
  if globalVendors.length > 0
    gulp.src globalVendors
      .pipe $.concat globalVendorsFileName
      .pipe if $.util.env.production then $.uglify() else $.util.noop()
      .pipe gulp.dest globalVendorsPath

# Copy the chromeapp manifests to build
gulp.task 'build:chrome', ['build:web'], (finishedTask) ->
  gulp.src [
    "#{webBuildPath}/**/*"
    'chromeapp.js'
    'manifest.json'
    'manifest.mobile.json'
  ]
    .pipe gulp.dest "#{chromeBuildPath}"
    .on 'end', finishedTask

gulp.task 'build:android', ['build:cordova']
gulp.task 'build:ios', ['build:cordova']

gulp.task 'build:cordova', ['build:chrome'], ->
  # Path exists is harmless. Use this to avoid scary log output
  pathExistsPattern = /Path already exists/g
  createCordova = ->
    new Promise (resolve, reject) ->
      cmd = 'cca create cordova --link-to=chrome'
      childProcess.exec cmd, cwd: buildPath, (error, stdout, stderr) ->
        $.util.log cyan stdout
        if error
          if error.toString().match pathExistsPattern
            $.util.log cyan 'Cordova project already exists'
            resolve()
          else
            $.util.log red 'build:cordova: createCordova() failed'
            $.util.log red "\t#{error}"
            reject error
        else
          resolve()
  prepareCordova = ->
    new Promise (resolve, reject) ->
      cmd = 'cca prepare'
      childProcess.exec cmd, cwd: cordovaPath, (error, stdout, stderr) ->
        $.util.log cyan stdout
        if error
          if error.toString().match pathExistsPattern
            $.util.log cyan 'Cordova project already exists'
            resolve()
          else
            $.util.log red 'build:cordova: createCordova() failed'
            $.util.log red "\t#{error}"
            reject error
        else
          resolve()

  createCordova().then prepareCordova

gulp.task 'dist', [
  'dist:web'
  'dist:chrome'
  'dist:android'
  'dist:ios'
]

gulp.task 'dist:web', ['build:web'], ->
  gulp.src [
      "#{webBuildPath}/src/*.js"
      "!#{webBuildPath}/src/test.js"
    ]
    .pipe $.uglify()
    .pipe gulp.dest "#{webDistPath}/src"
  gulp.src [
      "#{webBuildPath}/**/*"
      "!#{webBuildPath}/{src,src/**}"
    ]
    .pipe gulp.dest webDistPath

gulp.task 'dist:chrome', ['build:chrome'], ->
  # Allow a different chrome location to be passed on the command line
  chrome = $.util.env.chrome or defaultChromeLocation
  cmd = "'#{chrome}' --pack-extension=build/chrome --pack-extension-key=chromeapp.pem"

  packageChrome = ->
    new Promise (resolve, reject) ->
      childProcess.exec cmd, cwd: projectPath, (error, stdout, stderr) ->
        if error
          $.util.log red 'dist:chrome failed:'
          $.util.log red "\t#{stderr}"
          reject()
        else
          resolve()

  movePackage = ->
    new Promise (resolve, reject) ->
      src = "#{buildPath}/chrome.crx"
      dest = "#{chromeDistPath}"
      gulp.src src
        .pipe $.rimraf force: true
        .pipe $.rename chromePackageName
        .pipe gulp.dest chromeDistPath
        .on 'end', resolve

  packageChrome().then movePackage

gulp.task 'dist:android', ['build:cordova'], (finishedTask) ->
  childProcess.exec './build --release', cwd: "#{cordovaPath}/platforms/android/cordova", (error, stdout, stderr) ->
    if error
      $.util.log red 'dist:android failed:'
      $.util.log red "\t#{stderr}"
    else
      gulp.src "#{cordovaPath}/platforms/android/ant-build/*.apk"
        .pipe gulp.dest androidDistPath
    finishedTask()

gulp.task 'dist:ios', ['build:cordova'], ->
  $.util.log "\t#{blue 'TODO: build .ipa'}"

do (serverOpts = [
  'build:web'
  'build:test'
  'webserver'
  'watch'
]) ->
  serverOpts.push 'browse' if $.util.env.open
  gulp.task 'run:web', serverOpts, ->
    $.livereload.listen lrPort, (err) ->
      $.util.log err if err

gulp.task 'run:test', ['build:test'], ->
  gulp.src "#{jsBuildPath}/test.js", read: false
    .pipe $.mocha reporter: 'nyan'

gulp.task 'run:ios', ['build:cordova'], (finishedTask) ->
  cmd = "cca run ios #{if $.util.env.emulator then '--emulator' else ''}"
  childProcess.exec cmd, cwd: cordovaPath, (error, stdout, stderr) ->
    if error
      $.util.log red 'ios failed:'
      $.util.log red "\t#{stderr}"
    finishedTask()

gulp.task 'run:android', ['build:cordova'], (finishedTask) ->
  cmd = "cca run android #{if $.util.env.emulator then '--emulator' else ''}"
  childProcess.exec cmd, cwd: cordovaPath, (error, stdout, stderr) ->
    if error
      $.util.log red 'android failed:'
      $.util.log red "\t#{stderr}"
    finishedTask()

gulp.task 'run:chrome', ['dist:chrome'], (finishedTask) ->
  $.util.log "\t#{blue 'TODO'}"
  # # Allow a different chrome location to be passed on the command line
  # chrome = $.util.env.chrome or defaultChromeLocation
  # cmd = "'#{chrome}' #{chromeDistPath}/#{chromePackageName}"
  # $.util.log "Running #{blue cmd}"
  # childProcess.exec cmd, cwd: projectPath, (error, stdout, stderr) ->
  #   if error
  #     $.util.log red 'run:chrome failed:'
  #     $.util.log red "\t#{stderr}"

gulp.task 'default', ['build']

