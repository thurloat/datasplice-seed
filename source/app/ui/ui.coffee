Radium = require 'radium'

Navbar = React.createFactory require './navbar'
AppMenu = React.createFactory require './appmenu'
SearchDrawer = React.createFactory require './searchdrawer'
Content = React.createFactory require './content'

Style = React.createFactory Radium.Style
{ appRules } = require './stylevariables'

{ div } = React.DOM

UI = React.createClass
  displayName: 'UI'

  getInitialState: ->
    menuOpen: false
    searchOpen: false

  componentDidMount: ->
    _.delay ->
      console.warn 'scroll'
      window.scrollTo 0, 1
    , 1000

  render: ->
    div
      style:
        marginTop: '50px'
    ,
      AppMenu
        open: @state.menuOpen
        hide: _.bind @_appMenu, null, false

      Navbar
        showMenu: _.bind @_appMenu, null, true
        showSearch: _.bind @_searchDrawer, null, true

      SearchDrawer
        open: @state.searchOpen
        hide: _.bind @_searchDrawer, null, false

      Content null

      Style rules: appRules

  _appMenu: (open) ->
    @setState if open
      menuOpen: true
      searchOpen: false
    else
      menuOpen: false

  _searchDrawer: (open) ->
    @setState if open
      searchOpen: true
      menuOpen: false
    else
      searchOpen: false

module.exports = UI
