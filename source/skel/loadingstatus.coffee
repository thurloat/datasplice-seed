require './loadingstatus.less'

{ div, span } = React.DOM
{ classSet } = React.addons

LoadingStatus = React.createClass
  displayName: 'LoadingStatus'

  propTypes:
    progress: React.PropTypes.string
    error: React.PropTypes.string

  render: ->
    div className: 'loading-status',
      div
        className: classSet
          logo: true
          loading: not @props.error
          error: @props.error?
      ,
        div className: 'message', @props.error or @props.progress

module.exports = LoadingStatus
