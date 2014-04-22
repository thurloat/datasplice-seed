_ = require 'lodash'
async = require 'async'
React = require 'react'
When = require 'when'

{ blockquote, h3, ul, li, a } = React.DOM

Versions = React.createClass
  displayName: 'Versions'

  render: ->
    blockquote {},
      h3 {}, 'Available libraries:'

      ul {},
        li {},
          a href: 'http://lodash.com/', 'Lo-Dash'
          " [#{_.VERSION}]"
        li {},
          a href: 'https://github.com/caolan/async/', 'Async.js'
          " [0.2.10?]"
        li {},
          a href: 'http://facebook.github.io/react/', 'React'
          " [#{React.version}]"
        li {},
          a href: 'https://github.com/cujojs/when', 'when.js'
          " [2.7.1?]"

module.exports = Versions


