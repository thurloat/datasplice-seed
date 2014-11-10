require './lessexample.less'

{ div, p, a, span } = React.DOM

LessExample = React.createClass
  displayName: 'LessExample'

  render: ->
    div className: 'less-example',
      p null,
        'The app uses SASS by default (including '
        a href: 'http://getbootstrap.com/', 'Bootstrap'
        ' and '
        a href: 'http://fontawesome.io/', 'Font Awesome'
        '), but also supports defining stylesheets with '
        a href: 'http://lesscss.org/', 'Less.js'

      span className: 'content', 'Example content'

module.exports = LessExample
