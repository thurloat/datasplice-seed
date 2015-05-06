# { Map, Marker, Popup, TileLayer } = require 'react-leaflet'
ReactLeaflet = require 'react-leaflet'
Map = React.createFactory ReactLeaflet.Map
Marker = React.createFactory ReactLeaflet.Marker
Popup = React.createFactory ReactLeaflet.Popup
TileLayer = React.createFactory ReactLeaflet.TileLayer

Radium = require 'radium'
Style = React.createFactory Radium.Style

{ div, span } = React.DOM

require 'leaflet/dist/leaflet.css'

MapContent = React.createClass
  displayName: 'MapContent'

  propTypes:
    position: React.PropTypes.arrayOf React.PropTypes.number
    zoom: React.PropTypes.number
    topOffset: React.PropTypes.string

  getDefaultProps: ->
    position: [ 51.505, -0.09 ]
    zoom: 13
    topOffset: 0
    rightOffset: 0
    bottomOffset: 0
    leftOffset: 0

  render: ->
    div
      className: 'map-content'
      style:
        position: 'absolute'
        top: @props.topOffset
        right: @props.rightOffset
        bottom: @props.bottomOffset
        left: @props.leftOffset
    ,
      Map
        center: @props.position
        zoom: @props.zoom
        style:
          height: '400px'
      ,
        TileLayer
          url: "http://{s}.tile.osm.org/{z}/{x}/{y}.png"
          attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        Marker position: @props.position,
          Popup null,
            span null, 'A pretty CSS3 popup'

      Style scopeSelector: '.map-content', rules: [
        '> .leaflet-container':
          height: '100%'
          width: '100%'
          margin: '0 auto'
      ]

module.exports = MapContent
