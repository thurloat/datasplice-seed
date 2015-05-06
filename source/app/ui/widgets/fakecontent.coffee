dimsum = require 'dimsum'

{ div, p } = React.DOM

require './_blokkfont.scss'

FakeContent = React.createClass
  displayName: 'FakeContent'

  propTypes:
    margin: React.PropTypes.string.isRequired
    textColor: React.PropTypes.string.isRequired
    paragraphs: React.PropTypes.number

  getDefaultProps: ->
    margin: '0 1em'
    textColor: '#999'
    paragraphs: 1

  componentWillMount: ->
    @setState text: (dimsum.generate @props.paragraphs).split /\n/

  componentWillReceiveProps: (nextProps) ->
    if nextProps.paragraphs isnt @props.paragraphs
      @setState text: (dimsum.generate nextProps.paragraphs).split /\n/

  render: ->
    div style: { margin: @props.margin },
      for line, index in @state.text
        p key:index, className: 'blokk', style: { color: @props.textColor },
          line

module.exports = FakeContent
