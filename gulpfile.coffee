_             = require 'lodash'
childProcess  = require 'child_process'
connect       = require 'connect'
del           = require 'del'
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

jsBuildPath     = "#{buildPath}/js"
webBuildPath    = "#{buildPath}/web"
testBuildPath   = "#{buildPath}/test"

globalVendorsPath = "#{webBuildPath}/vendor"
globalVendorsFileName = 'global.js'

webDistPath       = "#{distPath}/web"

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

gulp.task 'clean:build', (cb) ->
  del [ buildPath ], cb

gulp.task 'clean:dist', (cb) ->
  del [ distPath ], cb

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

gulp.task 'dist', [
  'dist:web'
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

gulp.task 'default', ['build']
