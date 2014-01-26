do (
  React = require 'react'
) ->

  {div} = React.DOM

  Jumbotron = React.createClass

    propTypes:
      fullWidth: React.PropTypes.bool

    getDefaultPropTypes:
      fullWidth: true

    render: ->
      div className: 'jumbotron',
        if @props.fullWidth
          div className: 'container',
            @props.children
        else
          @props.children

  module.exports = Jumbotron
