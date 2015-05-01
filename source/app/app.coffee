require 'font-awesome-webpack'
require './bootstrap.scss'
require './app.scss'

LibraryVersions = require './libraryversions'
UI = React.createFactory require './ui/ui'

mountPoint = document.querySelector '#app'
ui = UI libraryInfo: LibraryVersions

React.render ui, mountPoint
