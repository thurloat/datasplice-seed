Drawer = React.createFactory require './widgets/drawer'

DetailsDrawer = React.createClass
  displayName: 'DetailsDrawer'

  propTypes:
    open: React.PropTypes.bool.isRequired
    hide: React.PropTypes.func.isRequired

  render: ->
    Drawer
      title: 'Details'
      toggleIcon: 'ellipsis-v'
      open: @props.open
      position: 'right'
      topOffset: 51
      width: 175
      hide: @props.hide

module.exports = DetailsDrawer
