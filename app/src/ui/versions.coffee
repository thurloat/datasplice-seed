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
          a href: 'http://facebook.github.io/react/', 'React'
          " [#{React.version}]"
        li {},
          a href: 'https://github.com/caolan/async/', 'Async.js'
        li {},
          a href: 'https://github.com/cujojs/when', 'when.js'

module.exports = Versions

