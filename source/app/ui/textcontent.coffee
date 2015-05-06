FakeContent = React.createFactory require './widgets/fakecontent'

cx = require 'classnames'
{ div, ul, li, a } = React.DOM

TextContent = React.createClass
  displayName: 'TextContent'

  getInitialState: ->
    paragraphs: 5

  render: ->
    div style: { marginTop: '1em' },
      ul
        className: 'pagination'
        style: { margin: '0 1em' }
      ,
        for count in [ 1..10 ]
          li { key: count, className: cx active: count is @state.paragraphs },
            a { onClick: _.bind @_count, null, count }, count

      FakeContent paragraphs: @state.paragraphs

  _count: (count) ->
    @setState paragraphs: count

module.exports = TextContent
