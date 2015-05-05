require 'font-awesome-webpack'
require './bootstrap.scss'

UI = React.createFactory require './ui/ui'

mountPoint = document.querySelector '#app'
ui = UI null

React.render ui, mountPoint
