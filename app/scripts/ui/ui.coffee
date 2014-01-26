do (
  React = require 'react'
  Jumbotron = require './jumbotron/jumbotron'
) ->

  {img, h1} = React.DOM

  UI = React.createClass
    render: ->
      Jumbotron {},
        h1 {},
          'Ready...'
        img src: 'images/datasplice_logo.jpg'

  module.exports = UI
