require './environment'
UI = require './ui/ui'

mountPoint = document.getElementById 'app'
ui = UI {}
React.renderComponent ui, mountPoint

