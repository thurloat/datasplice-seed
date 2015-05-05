Radium = require 'radium'
styleVariables = require '../stylevariables'

cx = require 'classnames'
{ div, ul, li, a, i } = React.DOM

getStyles = (props) ->
  base:
    position: 'absolute'
    top: "#{props.topOffset}px"
    bottom: 0
    width: "#{props.width}px"
    zIndex: props.zIndex
    display: 'none'
    backgroundColor: styleVariables.drawerBackground

  open:
    display: 'block'

  left:
    left: 0

  right:
    right: 0

Drawer = React.createClass Radium.wrap
  displayName: 'Drawer'

  propTypes:
    title: React.PropTypes.string.isRequired
    toggleIcon: React.PropTypes.string.isRequired
    open: React.PropTypes.bool.isRequired
    position: React.PropTypes.oneOf [ 'left', 'right' ]
    topOffset: React.PropTypes.number.isRequired
    width: React.PropTypes.number.isRequired
    hide: React.PropTypes.func.isRequired

  getDefaultProps: ->
    topOffset: 0
    width: 200
    zIndex: 1050
    position: 'left'

  render: ->
    styles = getStyles @props

    div
      className: 'drawer'
      style: [
        styles.base
        styles.open if @props.open
        styles.left if @props.open and @props.position is 'left'
        styles.right if @props.open and @props.position is 'right'
      ]
    ,
      div
        className: 'navbar navbar-default',
        style:
          borderRadius: 0
      ,
        ul
          className: cx 'nav navbar-nav',
            'navbar-right': @props.position is 'right'
          style: { margin: 0 }
        ,
          li null,
            a onClick: @props.hide,
              i className: "fa fa-#{@props.toggleIcon}"
        a className: 'navbar-brand', @props.title

module.exports = Drawer
