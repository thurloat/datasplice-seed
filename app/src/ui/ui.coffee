do (
  React = require 'react'
  Jumbotron = require './jumbotron/jumbotron'
) ->

  {img, h1, h3, a} = React.DOM

  UI = React.createClass
    render: ->
      Jumbotron {},
        h1 {},
          'Ready...'
        img src: 'images/datasplice_logo.jpg'
        h3 {},
          a href: 'test.html',
            'Mocha Tests'

  module.exports = UI
