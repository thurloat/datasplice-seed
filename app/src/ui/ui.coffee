Versions = require './versions'
Jumbotron = require './widgets/jumbotron'

{div, i, img, h1, a, p, pre} = React.DOM

UI = React.createClass
  displayName: 'UI'

  render: ->
    div className: 'container',
      Jumbotron fullWidth: false,
        h1 {},
          i className: 'fa fa-leaf'
          ' Ready...'
        p {},
          a href: 'test.html', className: 'btn btn-primary btn-lg', role: 'button',
            'Mocha Tests'
        p {},
          'Change your git remote:'
        pre {},
          'git remote set-url origin https://github.com/DataSplice/<your-project>'

        Versions {}

module.exports = UI
