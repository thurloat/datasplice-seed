gulp = require 'gulp'
http = require 'http'
path = require 'path'
lr = require 'tiny-lr'
open = require 'gulp-open'
sass = require 'gulp-sass'
connect = require 'connect'
mocha = require 'gulp-mocha'
gutil = require 'gulp-util'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
embedlr = require 'gulp-embedlr'
refresh = require 'gulp-livereload'
browserify = require 'gulp-browserify'
server = do lr

fileset = (base) ->
  base: base
  images: "#{base}/images"
  scripts: "#{base}/scripts"
  styles: "#{base}/styles"

browserifyOptions =
  debug: not gulp.env.production
  transform: ['coffeeify']
  extensions: ['.coffee']   # extension to skip when calling require()

app = fileset './app'
dist = fileset './dist'
port = 3000
# allow to connect from anywhere
hostname = null

# Starts the webserver
gulp.task 'webserver', ->
  application = connect()
    # allows import of npm css
    .use(connect.static path.resolve './node_modules')
    .use(connect.static path.resolve "#{dist.base}")
    .use(connect.directory path.resolve "#{dist.base}")
  (http.createServer application).listen port, hostname

# Copies images to dest then reloads the page
gulp.task 'images', ->
  (gulp.src "#{app.images}/**/*")
    .pipe(gulp.dest "#{dist.images}")
    .pipe(refresh server)

gulp.task 'scripts', ->
  (gulp.src "#{app.scripts}/main.coffee", read: false)
    .pipe(browserify browserifyOptions)
    .pipe(concat 'main.js')
    .pipe(if gulp.env.production then uglify() else gutil.noop())
    .pipe(gulp.dest "#{dist.scripts}")
    .pipe(refresh server)

# Compiles Sass files into css file
# and reloads the styles
gulp.task 'styles', ->
  (gulp.src "#{app.styles}/main.scss")
    # TODO: should include pattern for styles from React components
    .pipe(sass includePaths: ['styles/includes'])
    .pipe(concat 'main.css')
    .pipe(gulp.dest "#{dist.styles}")
    .pipe(refresh server)

# Copy the HTML to dist
gulp.task 'html', ->
  (gulp.src "#{app.base}/*.html")
    # embeds the live reload script
    .pipe(if gulp.env.production then gutil.noop() else embedlr())
    .pipe(gulp.dest "#{dist.base}")
    .pipe(refresh server)

gulp.task 'livereload', ->
  server.listen 35729, (err) ->
    return (console.log err) if err

# Watches files for changes
gulp.task 'watch', ->
  gulp.watch "#{app.images}/**", ->
    gulp.run 'images'

  gulp.watch "#{app.scripts}/**", ->
    gulp.run 'scripts'

  gulp.watch "#{app.styles}/**", ->
    gulp.run 'styles'

  gulp.watch "#{app.base}/*.html", ->
    gulp.run 'html'

# Opens the app in your browser
gulp.task 'url', ->
  options = url: "http://localhost:#{port}"
  gulp.src("#{dist.base}/index.html")
    .pipe(open("", options))

gulp.task 'clean', ->
  (gulp.src "#{dist.base}", read: false)
    .pipe(clean force: true)

gulp.task 'package', ['images', 'html', 'scripts', 'styles'], ->
  gulp.run 'url' if gulp.env.open

gulp.task 'test', ->
  (gulp.src "#{app.scripts}/test.coffee", read: false)
    .pipe(browserify browserifyOptions)
    .pipe(mocha reporter: 'nyan')
    .on('error', gutil.log)

# The default task.
#
# Options:
#   --production  : minifies JS
#   --open        : opens application in browser
#
gulp.task 'default', ['clean'], ->
  gulp.run 'webserver', 'livereload', 'watch', 'package'
