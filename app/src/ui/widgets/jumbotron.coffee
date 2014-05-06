{div} = React.DOM

Jumbotron = React.createClass
  displayName: 'Jumbotron'

  propTypes:
    fullWidth: React.PropTypes.bool

  getDefaultPropTypes:
    fullWidth: true

  render: ->
    contents = if @props.fullWidth
      div className: 'container',
        @props.children
    else
      @props.children

    div className: 'jumbotron',
      contents

module.exports = Jumbotron
