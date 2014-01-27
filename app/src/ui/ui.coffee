do (
  React = require 'react'
  Jumbotron = require './jumbotron/jumbotron'
) ->

  {img, h1, a, p, pre} = React.DOM

  UI = React.createClass
    render: ->
      Jumbotron fullWidth: false,
        h1 {},
          'Ready...'
        p {},
          'Change your git remote with'
        pre {},
          'git remote set-url origin https://github.com/DataSplice/<your-project>'
        p {},
          img src: 'images/datasplice_logo.jpg'
        p {},
          a href: 'test.html', className: 'btn btn-primary btn-lg', role: 'button',
            'Mocha Tests'

  module.exports = UI
