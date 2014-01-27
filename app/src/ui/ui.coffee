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
          a href: 'test.html', className: 'btn btn-primary btn-lg', role: 'button',
            'Mocha Tests'
        p {},
          'Change your git remote with'
        pre {},
          'git remote set-url origin https://github.com/DataSplice/<your-project>'
        p {},
          'Main gulp tasks'
        pre {},
          """
          gulp                        # defaults to [clean, build]
          gulp clean                  # deletes build dir
          gulp test                   # runs nyancat in the console
          gulp build  [--production]  # compiles and creates build/dist and build/test, [--production] flag minifies js/css files in build/dist
          gulp server [--open]        # starts dev server, [--open] flag opens your browser automatically
          """
        p {},
          img src: 'images/datasplice_logo.jpg'

  module.exports = UI
