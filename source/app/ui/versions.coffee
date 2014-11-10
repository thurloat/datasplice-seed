{ blockquote, h3, ul, li, a } = React.DOM

# ensure we have references to shared libaries to consolidate them in the
# common vendor script
[ _, React, async ]

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

module.exports = Versions

