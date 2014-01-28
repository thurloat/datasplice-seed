do (
  React = require 'react'
  Jumbotron = require './jumbotron/jumbotron'
) ->

  {div, span, img, h1, a, p, pre} = React.DOM

  UI = React.createClass
    render: ->
      div className: 'container',
        Jumbotron fullWidth: false,
          h1 {},
            span className: 'glyphicon glyphicon-leaf'
            ' Ready...'
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
            gulp                            # defaults to [clean, build]
            gulp clean                      # deletes build dir
            gulp test                       # runs nyancat in the console
            gulp build  [--production]      # builds src and test code
                                            # [--production] flag minifies js/css files in build/dist
            gulp server [--open] [--lrport] # starts dev server
                                            # [--open] flag opens your browser automatically
                                            # [--lrport[ flag specifies live reload port (35729 by default)
            """

  module.exports = UI
