gulp = require 'gulp'
http = require 'http'
path = require 'path'
lr = require 'tiny-lr'
open = require 'gulp-open'
sass = require 'gulp-sass'
connect = require 'connect'
gutil = require 'gulp-util'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
embedlr = require 'gulp-embedlr'
mocha = require 'gulp-spawn-mocha'
refresh = require 'gulp-livereload'
browserify = require 'gulp-browserify'
server = do lr

fileset = (base) ->
  base: base
  images: "#{base}/images"
  scripts: "#{base}/scripts"
  styles: "#{base}/styles"

minify = ->
  if gulp.env.production then uglify() else gutil.noop()

app = fileset './app'
dist = fileset './dist'
port = 3000
hostname = null # allow to connect from anywhere
base = path.resolve "#{dist.base}"
directory = path.resolve "#{dist.base}"

# Starts the webserver (http://localhost:3000)
gulp.task 'webserver', ->
  application = connect()
    .use(connect.static base)
    .use(connect.directory directory)
  (http.createServer application).listen port, hostname

# Copies images to dest then reloads the page
gulp.task 'images', ->
  (gulp.src "#{app.images}/**/*")
    .pipe(gulp.dest "#{dist.images}")
    .pipe(refresh server)

# Compiles CoffeeScript files into js file
# and reloads the page
gulp.task 'coffee', ->
  (gulp.src "#{app.scripts}/**/*.coffee")
    .pipe(coffee bare: true).on('error', gutil.log)
    .pipe(gulp.dest './.tmp')

# NOTE: Intentionally not using browserify to transform the coffee
#   See: https://github.com/deepak1556/gulp-browserify/pull/14/files
# gulp.task 'scripts', ['coffee'], ->
#   (gulp.src './.tmp/main.js')
#     .pipe(browserify insertGlobals: true, debug: not gulp.env.production)
#     .pipe(minify())
#     .pipe(gulp.dest "#{dist.scripts}")
#     .pipe(refresh server)

# NOTE: Intentionally not using browserify to transform the coffee
#   See: https://github.com/deepak1556/gulp-browserify/pull/14/files
gulp.task 'scripts', ->
  (gulp.src "#{app.scripts}/main.coffee", { read: false })
    .pipe(browserify
      debug: not gulp.env.production
      insertGlobals: true
      transform: ['coffeeify']
      extensions: ['.coffee']   # extension to skip when calling require()
    )
    .pipe(concat 'main.js')
    .pipe(minify())
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
    .pipe(do embedlr) # embeds the live reload script
    .pipe(gulp.dest 'dist')
    .pipe(refresh server)

# Watches files for changes
gulp.task 'watch', ->
  server.listen 35729, (err) ->
    return (console.log err) if err

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
  (gulp.src '.tmp', read: false)
    .pipe(clean force: true)

gulp.task 'package', ['images', 'html', 'scripts', 'styles'], ->
  gulp.run 'url' if gulp.env.open

# The default task
# Run with --production for minification of JS
gulp.task 'default', ['clean'], ->
  gulp.run 'webserver', 'watch', 'package'
