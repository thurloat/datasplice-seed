Jumbotron = require './widgets/jumbotron'
LessExample = require './lessexample'
LibraryVersions = require './libraryversions'

{ div, i, img, h1, h3, a, p, pre } = React.DOM

UI = React.createClass
  displayName: 'UI'

  render: ->
    div className: 'container',
      Jumbotron fullWidth: false,
        h1 null,
          i className: 'fa fa-leaf'
          ' Seed Application Loaded'
        p null,
          'Flexible application framework supporting offline caching, dynamic
          application manifests, and other cool stuff'

        Panel title: 'LESS Support',
          LessExample null

        Panel title: 'Available Libraries',
          LibraryVersions
            libraryInfo: [
              label: 'Lo-Dash'
              url: 'http://lodash.com'
              version: -> _.VERSION
            ,
              label: 'React'
              url: 'http://facebook.github.io/react/index.html'
              version: -> React.version
            # todo - webpack, bootstrap, font-awesome, etc
            ]

Panel = React.createClass
  displayName: 'panel'

  propTypes:
    title: React.PropTypes.string.isRequired

  render: ->
    div className: 'panel panel-info',
      div className: 'panel-heading',
        h3 className: 'panel-title', @props.title
      div className: 'panel-body',
        @props.children

module.exports = UI
