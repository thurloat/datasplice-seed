require './loadingstatus.less'

{ div, span } = React.DOM
cx = require 'classnames'

LoadingStatus = React.createClass
  displayName: 'LoadingStatus'

  propTypes:
    progress: React.PropTypes.string
    error: React.PropTypes.string

  render: ->
    div className: 'loading-status',
      div
        className: cx 'logo',
          loading: not @props.error
          error: @props.error?
      ,
        div className: 'message', @props.error or @props.progress

module.exports = LoadingStatus
