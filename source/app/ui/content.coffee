DetailsDrawer = React.createFactory require './detailsdrawer'

{ div, ul, li, a, i } = React.DOM

Content = React.createClass
  displayName: 'Content'

  getInitialState: ->
    detailsOpen: false

  render: ->
    div className: 'content',
      DetailsDrawer
        open: @state.detailsOpen
        hide: _.bind @_details, null, false

      Actions
        showDetails: _.bind @_details, null, true

  _details: (open) ->
    @setState detailsOpen: open

Actions = React.createFactory React.createClass
  displayName: 'Actions'

  propTypes:
    showDetails: React.PropTypes.func.isRequired

  render: ->
    div
      className: 'navbar navbar-default'
      style:
        borderRadius: 0
    ,
      div className: 'container-fluid',
        ul className: 'nav navbar-nav',
          li null, a null, i className: 'fa fa-table'
          li null, a null, i className: 'fa fa-th-list'
          li null, a null, i className: 'fa fa-globe'
        ul className: 'nav navbar-nav navbar-right',
          li null,
            a onClick: @props.showDetails,
              i className: 'fa fa-ellipsis-v'

module.exports = Content
