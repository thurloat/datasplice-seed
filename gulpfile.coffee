_ = require 'lodash'
del = require 'del'
path = require 'path'

gulp = require 'gulp'
$ = do require 'gulp-load-plugins'
runSequence = require 'run-sequence'

webpack = require 'webpack'

devServer = require './gulp/devserver'
AppManifestPlugin = require './gulp/appmanifestplugin'

{ red, cyan, blue, green, magenta } = $.util.colors

projectPath = path.resolve __dirname
paths =
  base:   projectPath
  source: "#{projectPath}/source"
  build:  "#{projectPath}/build"
  skel:   "#{projectPath}/build/skel"
  app:    "#{projectPath}/build/app"
  dist:   "#{projectPath}/dist"

# load and update the config settings for Webpack
skelConfig = (require './skel.webpack.config') paths
skelConfig.plugins or= []
appConfig = (require './app.webpack.config') paths
appConfig.plugins or= []

# automatically expose shared libraries
if skelConfig.sharedLibraries
  skelConfig.plugins.push new webpack.ProvidePlugin skelConfig.sharedLibraries
  appConfig.plugins.push new webpack.ProvidePlugin skelConfig.sharedLibraries

  # these need to be registered as external dependencies in the app so they
  # are only bundled once
  appConfig.externals = _.invert skelConfig.sharedLibraries

# create a manifest of the files packaged for the app - skip the unit tests
appConfig.plugins.push new AppManifestPlugin skip: 'test.js'

uglifyIfNeeded = (config) ->
  if $.util.env.production
    config.plugins or= []
    uglifyOptions = compress: warnings: false
    config.plugins.push new webpack.optimize.UglifyJsPlugin uglifyOptions

# entry tasks

gulp.task 'default', [ 'run' ]

gulp.task 'build', [ 'build:skel', 'build:app' ]

gulp.task 'dist', (cb) ->
  runSequence 'build', 'build:dist', cb

gulp.task 'run', [ 'build:skel' ], ->
  gulp.start 'run:webpack'

gulp.task 'test', (cb) ->
  runSequence 'dist', 'run:mocha', cb

gulp.task 'clean', (cb) ->
  del [ paths.build, paths.dist ], cb


# build tasks

# static skeleton resources
gulp.task 'build:static', ->
  gulp.src [ "#{paths.source}/*.html", "#{paths.source}/favicon.ico" ]
    .pipe gulp.dest "#{paths.skel}"

# skeleton application, shared libraries, etc
gulp.task 'build:skel', ['build:static'], (cb) ->
  uglifyIfNeeded skelConfig
  webpack skelConfig, (err, stats) ->
    $.util.log '[skel:src]', stats.toString colors: true
    cb err

gulp.task 'build:app', (cb) ->
  uglifyIfNeeded appConfig

  webpack appConfig, (err, stats) ->
    $.util.log '[app:src]', stats.toString colors: true
    cb err

gulp.task 'build:dist', ->
  gulp.src [ "#{paths.skel}/**/*", "#{paths.app}/**/*" ]
    .pipe gulp.dest paths.dist

# run tasks

gulp.task 'run:webpack', ->
  compiler = webpack appConfig
  devServer compiler, "#{paths.skel}"

gulp.task 'run:mocha', ->
  gulp.src "#{paths.dist}/test.html"
    .pipe $.mochaPhantomjs reporter: './node_modules/mocha/lib/reporters/nyan.js'
