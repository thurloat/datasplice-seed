{ blockquote, ul, li, a, span } = React.DOM

VersionInfo = React.createClass
  displayName: 'VersionInfo'

  propTypes:
    libraryInfo: (React.PropTypes.arrayOf React.PropTypes.shape
      key: React.PropTypes.string.isRequired
      label: React.PropTypes.string.isRequired
      url: React.PropTypes.string.isRequired
      version: React.PropTypes.func.isRequired
    ).isRequired

  render: ->
    blockquote style: { marginBottom: 0 },
      ul null,
        for info in @props.libraryInfo
          li key: info.key,
            a href: info.url, info.label
            span null, " [#{info.version()}]"

module.exports = VersionInfo
