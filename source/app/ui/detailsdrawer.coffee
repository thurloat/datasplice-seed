Drawer = React.createFactory require './widgets/drawer'
FakeContent = React.createFactory require './widgets/fakecontent'

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
    ,
      FakeContent paragraphs: 2

module.exports = DetailsDrawer
