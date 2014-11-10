webpack = require 'webpack'
AppCachePlugin = require 'appcache-webpack-plugin'

module.exports = (paths) ->
  entry: "#{paths.source}/skel/skel.coffee"
  output:
    path: "#{paths.build}/skel"
    filename: 'skel.js'
  resolve:
    extensions: [
      ''
      '.coffee'
      '.js'
    ]
  module:
    loaders: [
      test: /\.coffee$/
      loader: 'coffee-loader'
    ,
      test: /\.less$/
      loader: 'style-loader!css-loader!less-loader'
    ,
      test: /\.(scss|sass)$/
      loader: 'style-loader!css-loader!sass-loader'
    ,
      test: /.(eot|svg|ttf|woff)(\?v=[0-9]\.[0-9]\.[0-9])?$/
      loader: 'url-loader'
    ]
  plugins: [
    new AppCachePlugin
      cache: [ 'favicon.ico' ]
      network: [ '*', 'http://*', 'https://*' ]
  ]

  # non-standard config - shared libraries that are exposed as globals to
  # the app as well
  sharedLibraries:
    _: 'lodash'
    async: 'async'
    React: 'react/addons'
