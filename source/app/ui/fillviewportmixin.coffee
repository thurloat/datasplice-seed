module.exports =

  getDefaultProps: ->
    topOffset: 0
    rightOffset: 0
    bottomOffset: '-1px'
    leftOffset: 0

  fillStyle: ->
    position: 'absolute'
    top: @props.topOffset
    right: @props.rightOffset
    bottom: @props.bottomOffset
    left: @props.leftOffset
    overflow: 'auto'
    webkitOverflowScrolling: 'touch'
