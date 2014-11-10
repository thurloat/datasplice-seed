module.exports =
  [
    key: 'lodash'
    label: 'Lo-Dash'
    url: 'http://lodash.com'
    version: -> _.VERSION
  ,
    key: 'react'
    label: 'React'
    url: 'http://facebook.github.io/react/index.html'
    version: -> React.version
  # todo - webpack, bootstrap, font-awesome, etc
  ]
