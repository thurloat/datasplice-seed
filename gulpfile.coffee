_ = require 'lodash'
del = require 'del'
path = require 'path'

gulp = require 'gulp'
$ = do require 'gulp-load-plugins'

webpack = require 'webpack'

devServer = require './gulp/devserver'
AppManifestPlugin = require './gulp/appmanifestplugin'

{ red, cyan, blue, green, magenta } = $.util.colors

projectPath = path.resolve __dirname
paths =
  base:   projectPath
  source: "#{projectPath}/source"
  build:  "#{projectPath}/build"
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

appConfig.plugins.push new AppManifestPlugin


# entry tasks

gulp.task 'default', [ 'run' ]

gulp.task 'build', [ 'build:skel' ], ->
  gulp.start 'build:app'

gulp.task 'run', [ 'build:skel' ], ->
  gulp.start 'run:webpack'

gulp.task 'clean', (cb) ->
  del [ paths.build, paths.dist ], cb


# build tasks

# static skeleton resources
gulp.task 'build:static', ->
  gulp.src "#{paths.source}/index.html"
    .pipe gulp.dest "#{paths.build}/skel"

# skeleton application, shared libraries, etc
gulp.task 'build:skel', ['build:static'], (cb) ->
  unless $.util.env.nouglify
    skelConfig.plugins.push new webpack.optimize.UglifyJsPlugin
  webpack skelConfig, (err, stats) ->
    $.util.log '[skel:src]', stats.toString colors: true
    cb err

# gulp.task 'build:app', [ 'build:skel' ], (cb) ->
gulp.task 'build:app', (cb) ->
  unless $.util.env.nouglify
    appConfig.plugins.push new webpack.optimize.UglifyJsPlugin

  webpack appConfig, (err, stats) ->
    $.util.log '[app:src]', stats.toString colors: true
    cb err


# run tasks

gulp.task 'run:webpack', ->
  compiler = webpack appConfig
  devServer compiler, "#{paths.build}/skel"
