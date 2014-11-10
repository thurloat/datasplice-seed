$ = do require 'gulp-load-plugins'
WebpackDevServer = require 'webpack-dev-server'

{ red, cyan, blue, green, magenta } = $.util.colors

module.exports = (compiler, buildPath) ->
  port = $.util.env.listenport or 8080
  new WebpackDevServer compiler,
    contentBase: buildPath
    stats: { colors: true }
  .listen port, 'localhost', (err) ->
    if err
      throw new $.util.PluginError 'webpack-dev-server', err

    $.util.log (cyan '[webpack-dev-server]'),
      "Listening at http://localhost:#{port}"
