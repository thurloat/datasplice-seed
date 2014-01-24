do (
  React = require 'react'
  Jumbotron = require './jumbotron/jumbotron'
) ->

  UI = React.createClass
    render: ->
      Jumbotron {},
        'This is inside a jumbotron!'

  module.exports = UI
