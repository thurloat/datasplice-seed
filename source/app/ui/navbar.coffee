{ nav, div, ul, li, a, i, form, input } = React.DOM

Navbar = React.createClass
  displayName: 'Navbar'

  propTypes:
    showMenu: React.PropTypes.func.isRequired
    showSearch: React.PropTypes.func.isRequired

  render: ->
    nav className: 'navbar navbar-inverse navbar-fixed-top',
      div className: 'container-fluid',
        a className: 'navbar-brand', onClick: @props.showMenu,
          'App'
        ul className: 'nav navbar-nav navbar-right',
          li null,
            a onClick: @props.showSearch,
              i className: 'fa fa-search'

module.exports = Navbar
