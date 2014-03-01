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
            gulp                       # defaults to [clean, build]
            gulp clean                 # deletes build dir
            gulp clean:dist            # deletes dist dir
            gulp test                  # runs nyancat in the console
            gulp build  [--production] # builds src and test code
                                       # [--production] flag minifies js/css files in build/dist
            gulp dist                  # Builds distributions for Web/Chrome/Android/iOS
            """
          p {},
            'Web Tasks'
          pre {},
            """
            gulp web:build                   # Builds the webapp
            gulp web:run [--open] [--lrport] # Runs the webapp on port 3000
                                             # [--open] flag opens your browser automatically
                                             # [--lrport[ flag specifies live reload port (35729 by default)
            gulp web:dist                    # Copies the webapp to dist/web
            """
          p {},
            'Chrome Tasks'
          pre {},
            """
            gulp chrome:build   # Builds the chrome app
            gulp chrome:run     # Runs the chrome app
            gulp chrome:dist    # Packages the chrome app to dist/chrome
            """
          p {},
            'Android Tasks'
          pre {},
            """
            gulp android:run [--emulator]    # Run as Android app in connected device
                                             # [--emulator] runs in emulator instead of connected device
            """
          p {},
            'iOS Tasks'
          pre {},
            """
            gulp ios:run [--emulator]        # Run as iOS app in connected device
                                             # [--emulator] runs in emulator instead of connected device
            """

  module.exports = UI
