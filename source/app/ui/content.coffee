DetailsDrawer = React.createFactory require './detailsdrawer'
TextContent = React.createFactory require './textcontent'

cx = require 'classnames'
{ div, ul, li, a, i } = React.DOM

Content = React.createClass
  displayName: 'Content'

  getInitialState: ->
    mode: 'text'
    detailsOpen: false

  render: ->
    div className: 'content',
      DetailsDrawer
        open: @state.detailsOpen
        hide: _.bind @_details, null, false

      Actions
        mode: @state.mode
        setMode: @_setMode
        showDetails: _.bind @_details, null, true

      switch @state.mode
        when 'text'
          TextContent null

  _setMode: (mode) ->
    @setState { mode }

  _details: (open) ->
    @setState detailsOpen: open

Actions = React.createFactory React.createClass
  displayName: 'Actions'

  propTypes:
    mode: React.PropTypes.string.isRequired
    setMode: React.PropTypes.func.isRequired
    showDetails: React.PropTypes.func.isRequired

  render: ->
    types =
      text: 'font'
      table: 'table'
      list: 'th-list'
      map: 'globe'

    div
      className: 'navbar navbar-default'
      style:
        borderRadius: 0
    ,
      div className: 'container-fluid',
        ul className: 'nav navbar-nav',
          for mode, icon of types
            li { mode, className: cx active: @props.mode is mode },
              a onClick: (_.bind @props.setMode, null, mode),
                i className: "fa fa-#{icon}"
        ul className: 'nav navbar-nav navbar-right',
          li null,
            a onClick: @props.showDetails,
              i className: 'fa fa-ellipsis-v'

module.exports = Content
