require 'font-awesome-webpack'
require './bootstrap.scss'
require './app.scss'

UI = require './ui/ui'

mountPoint = document.querySelector '#app'
ui = UI {}
React.renderComponent ui, mountPoint
