webpack = require 'webpack'

module.exports = (paths) ->
  cache:true
  entry: "#{paths.source}/app/app.coffee"
  output:
    path: "#{paths.build}/app"
    filename: 'app.js'
  resolve:
    # Allow to omit extensions when requiring these files
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
      loader: 'style-loader!css-loader!sass-loader?\
        includePaths[]=node_modules'
    ,
      test: /.(eot|svg|ttf|woff)(\?v=[0-9]\.[0-9]\.[0-9])?$/
      loader: 'url-loader'
    ]
  plugins: [
    # this is needed for breakpoints to work with the chrome developer tools
    new webpack.BannerPlugin '//# sourceURL=app.js',
      raw: true
  ]
