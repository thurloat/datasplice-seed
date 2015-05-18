ReactLeaflet = require 'react-leaflet'
Map = React.createFactory ReactLeaflet.Map
Marker = React.createFactory ReactLeaflet.Marker
Popup = React.createFactory ReactLeaflet.Popup
TileLayer = React.createFactory ReactLeaflet.TileLayer

Radium = require 'radium'
Style = React.createFactory Radium.Style

FillViewportMixin = require './fillviewportmixin'

{ div, span } = React.DOM

require 'leaflet/dist/leaflet.css'

MapContent = React.createClass Radium.wrap
  displayName: 'MapContent'

  mixins: [ FillViewportMixin ]

  propTypes:
    position: React.PropTypes.arrayOf React.PropTypes.number
    zoom: React.PropTypes.number

  getDefaultProps: ->
    position: [ 51.505, -0.09 ]
    zoom: 13

  render: ->
    div
      className: 'map-content'
      style: [ @fillStyle() ]
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
