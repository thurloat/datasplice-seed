Drawer = React.createFactory require './widgets/drawer'

AppMenu = React.createClass
  displayName: 'AppMenu'

  propTypes:
    open: React.PropTypes.bool.isRequired
    hide: React.PropTypes.func.isRequired

  render: ->
    Drawer
      title: 'Wahoo'
      toggleIcon: 'remove'
      width: 300
      open: @props.open
      position: 'left'
      hide: @props.hide

module.exports = AppMenu
