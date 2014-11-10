# set up the environment, shared libararies, etc
require './environment'
require './skel.less'

ui = React.DOM.h1 null, 'Skeleton Placeholder'
React.renderComponent ui, document.querySelector '#app'
