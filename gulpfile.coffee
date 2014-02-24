_ = require 'lodash'
gulp = require 'gulp'
http = require 'http'
path = require 'path'
lr = require 'tiny-lr'
open = require 'gulp-open'
sass = require 'gulp-sass'
connect = require 'connect'
es = require 'event-stream'
gutil = require 'gulp-util'
clean = require 'gulp-clean'
mocha = require 'gulp-mocha'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'
embedlr = require 'gulp-embedlr'
refresh = require 'gulp-livereload'
minifycss = require 'gulp-minify-css'
exec = (require 'child_process').exec
browserify = require 'gulp-browserify'
server = do lr

fileset = (base) ->
  base: base
  images: "#{base}/images"
  src: "#{base}/src/"
  styles: "#{base}/styles"

browserifyOptions =
  debug: not gutil.env.production

vendorAssets = [
  {
    name: 'glyphicons'
    base: './bower_components/bootstrap-sass/fonts'
    assets: [
      { src: '*.*', dest: 'fonts', shared: true }
    ]
  }
]

app = fileset './app'
cordova = "./cordova"
build = './build'
dist = './dist'

js = "#{build}/js"
web = fileset "#{build}/web"
test = fileset "#{build}/test"
chrome = fileset "#{build}/chrome"
port = 3000
# allow to connect from anywhere
hostname = null
# change this to something unique if you want to run multiple projects
# side-by-side
lrPort = gutil.env.lrport or 35729

# Starts the webserver
gulp.task 'webserver', ->
  application = connect()
    # allows import of npm/bower resources
    .use(connect.static path.resolve './node_modules')
    .use(connect.static path.resolve './bower_components')
    # Mount the mocha tests
    .use(connect.static path.resolve "#{test.base}")
    # Mount the app
    .use(connect.static path.resolve "#{web.base}")
    .use(connect.directory path.resolve "#{web.base}")
  (http.createServer application).listen port, hostname

gulp.task 'coffee', ->
  gulp.src "#{app.src}/**/*.coffee"
    .pipe coffee bare: true
    .pipe gulp.dest "#{js}"

# Copies images to dest then reloads the page
gulp.task 'images', ->
  gulp.src "#{app.images}/**/*"
    .pipe gulp.dest "#{web.images}"
    .pipe refresh server

gulp.task 'scripts', ['coffee'], ->
  gulp.src "#{js}/index.js", read: false
    .pipe browserify browserifyOptions
    .on 'error', gutil.log
    .pipe rename 'index.js'
    .pipe if gutil.env.production then uglify() else gutil.noop()
    .pipe gulp.dest "#{web.src}"
    .pipe refresh server

gulp.task 'test-scripts', ['scripts'], ->
  gulp.src "#{js}/test.js", read: false
    .pipe browserify browserifyOptions
    .on 'error', gutil.log
    .pipe rename 'test.js'
    .pipe gulp.dest "#{test.src}"
    .pipe refresh server

# Compiles Sass files into css file
# and reloads the styles
gulp.task 'test-styles', ->
  gulp.src "node_modules/mocha/mocha.css"
    .pipe gulp.dest "#{test.styles}"
    .pipe refresh server

# Compiles Sass files into css file
# and reloads the styles
gulp.task 'styles', ->
  es.concat(
    gulp.src "#{app.styles}/index.scss"
      # TODO: should include pattern for styles from React components
      .pipe sass includePaths: ['styles/includes']
      .on 'error', gutil.log
    , gulp.src "bower_components/normalize-css/normalize.css"
  )
  .pipe rename 'index.css'
  .pipe if gutil.env.production then minifycss() else gutil.noop()
  .pipe gulp.dest "#{web.styles}"
  .pipe refresh server

# Copy the HTML to web
gulp.task 'html', ->
  gulp.src "#{app.base}/index.html"
    # embeds the live reload script
    .pipe if gutil.env.production then gutil.noop() else embedlr port: lrPort
    .pipe gulp.dest "#{web.base}"
    .pipe refresh server

# Copy the HTML to mocha
gulp.task 'test-html', ->
  gulp.src "#{app.base}/test.html"
    # embeds the live reload script
    .pipe embedlr()
    .pipe gulp.dest "#{test.base}"
    .pipe refresh server

gulp.task 'livereload', ->
  server.listen lrPort, (err) ->
    console.log err if err

# Watches files for changes
gulp.task 'watch', ->
  gulp.watch "#{app.images}/**", ['images']
  gulp.watch "#{app.src}/**", ['scripts', 'test-scripts']
  gulp.watch "#{app.src}/**/*.scss", ['styles']
  gulp.watch "#{app.styles}/**", ['styles']
  gulp.watch "#{app.base}/index.html", ['html']
  gulp.watch "#{app.base}/test.html", ['test-html']

# Opens the app in your browser
gulp.task 'browse', ->
  options = url: "http://localhost:#{port}"
  gulp.src "#{web.base}/index.html"
    .pipe open '', options

gulp.task 'clean', ->
  gulp.src ["#{build}", "#{cordova}/www/**/*"], read: false
    .pipe clean force: true

gulp.task 'build-web', ['build-vendor', 'html', 'images', 'styles', 'scripts']
gulp.task 'build-test', ['test-html', 'test-styles', 'test-scripts']

# Grabs assets from vendors and puts in build/web/vendor
# TODO: this doesn't seem very coffeescriptish
gulp.task 'build-vendor', ->
  cyan = gutil.colors.cyan
  for vendor in vendorAssets
    gutil.log "Building vendor #{cyan vendor.base}"
    for asset in vendor.assets
      src = "#{vendor.base}/#{asset.src}"
      # some assets assume a particular path in the file structure
      dest = if asset.shared
        "#{web.base}/#{asset.dest}"
      else
        "#{web.base}/vendor/#{vendor.name}/#{asset.dest}"
      gutil.log "\tCopying #{cyan src} to #{cyan dest}"
      gulp.src src
        .pipe gulp.dest dest

# Copy the chromeapp manifests to build
gulp.task 'build-chrome', ['build-web'], ->
  gulp.src [
    "#{web.base}/**/*"
    'chromeapp.js'
    'manifest.json'
    'manifest.mobile.json'
  ]
    .pipe gulp.dest "#{chrome.base}"

gulp.task 'build-cordova', ['build-chrome'], ->
  exec "cca prepare"

gulp.task 'dist-chrome', ['build-chrome'], ->
  console.log 'TODO'
  # exec "crx pack #{chrome.base} -f '#{build}/DataSpliceSeed.crx -p chromeapp.pem"

gulp.task 'dist-android', ->
  console.log 'TODO'

gulp.task 'dist-ios', ->
  console.log 'TODO'

gulp.task 'test', ['coffee'], ->
  gulp.src "#{js}/test.js", read: false
    .pipe browserify browserifyOptions
    .on 'error', gutil.log
    .pipe mocha reporter: 'nyan'
    .on 'error', gutil.log

do (serverOpts = ['build', 'webserver', 'livereload', 'watch']) ->
  serverOpts.push 'browse' if gutil.env.open
  gulp.task 'web', serverOpts

gulp.task 'ios', ['build-cordova'], ->
  process.chdir cordova
  exec "cca run ios #{if gutil.env.emulator then '--emulator' else ''}"

gulp.task 'android', ['build-cordova'], ->
  cyan = gutil.colors.cyan
  cmd = "cca run android #{if gutil.env.emulator then '--emulator' else ''}"
  process.chdir cordova
  gutil.log "\tSwitched to: #{cyan process.cwd()}"
  gutil.log "\tRunning: #{cyan cmd}"
  exec cmd

gulp.task 'build', ['build-chrome', 'build-cordova', 'build-web', 'build-test']

# https://github.com/gulpjs/gulp/blob/master/docs/API.md#async-task-support
gulp.task 'default', ['build']
