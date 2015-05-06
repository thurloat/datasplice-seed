Drawer = React.createFactory require './widgets/drawer'
FakeContent = React.createFactory require './widgets/fakecontent'

SearchDrawer = React.createClass
  displayName: 'SearchDrawer'

  propTypes:
    open: React.PropTypes.bool.isRequired
    hide: React.PropTypes.func.isRequired

  render: ->
    Drawer
      title: 'Search'
      toggleIcon: 'search'
      open: @props.open
      position: 'right'
      zIndex: 2000
      hide: @props.hide
    ,
      FakeContent paragraphs: 2

module.exports = SearchDrawer
