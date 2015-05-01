Jumbotron = React.createFactory require './widgets/jumbotron'
GulpTasks = React.createFactory require './gulptasks'
LessExample = React.createFactory require './lessexample'
VersionInfo = React.createFactory require './versioninfo'

{ div, i, h1, h3, a, p } = React.DOM

UI = React.createClass
  displayName: 'UI'

  propTypes:
    libraryInfo: React.PropTypes.array.isRequired

  render: ->
    div className: 'container',
      Jumbotron fullWidth: false,
        h1 null,
          i className: 'fa fa-leaf'
          ' Seed Application Loaded'
        p null,
          'Flexible application framework supporting offline caching, dynamic
          application manifests, and other cool stuff'

        Panel title: 'Gulp Tasks',
          GulpTasks null

        Panel title: 'LESS Support',
          LessExample null

        Panel title: 'Available Libraries',
          VersionInfo libraryInfo: @props.libraryInfo

Panel = React.createFactory React.createClass
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
