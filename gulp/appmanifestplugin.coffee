_ = require 'lodash'

Manifest = (files) ->
  content = JSON.stringify files

  # this is the asset interface expected by webpack
  size: -> Buffer.byteLength @source(), 'utf8'
  source: -> content

module.exports = (options) ->
  apply: (compiler) ->
    manifestName = options?.name or 'app-manifest.json'

    compiler.plugin 'emit', (compilation, cb) ->
      files = _.keys compilation.assets
      compilation.assets[manifestName] = new Manifest files
      cb()
