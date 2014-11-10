# set up the environment, shared libararies, etc
require './environment'
require './skel.less'

ui = React.DOM.h1 null, 'Skeleton Placeholder'
React.renderComponent ui, document.querySelector '#app'

AppLoader = require './apploader'
(AppLoader.loadApp
  progress: (notification) ->
    console.warn notification
  delay: 1000)
  .then ->
    console.warn 'app loaded'
  .catch (error) ->
    console.error error
