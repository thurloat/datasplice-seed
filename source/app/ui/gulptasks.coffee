require './gulptasks.scss'

{ div, h4, dl, dt, dd, code, ul, li, a } = React.DOM

GulpTasks = React.createClass
  displayName: 'GulpTasks'

  render: ->
    div className: 'gulp-tasks',
      dl style: { marginBottom: 0 },
        dt null, 'gulp clean'
        dd null, 'Clean build and dist folders'
        dt null, 'gulp build'
        dd null, 'Build skeleton and application files'
        dt null, 'gulp dist'
        dd null, 'Combine skeleton and application files into distributable package'
        dt null, 'gulp run'
        dd null, 'Run development server for app and unit tests (/test.html). \
                  Runs watch process for application files'
        dt null, 'gulp test'
        dd null,
          'Builds app and runs command line '
          a href: './test.html', target: '_blank', 'unit tests'

      h4 null, 'Flags'
      ul null,
        li null,
          code null, '--nouglify'
          " disable minification of JS and CSS (the run task doesn't minify the
          app files by default)"
        li null,
          code null, '--listenport'
          ' specifies the listen port for the run task (8080 by default)'

module.exports = GulpTasks
