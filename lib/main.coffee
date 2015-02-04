LineEndingConverter = require './line-ending-converter'
{CompositeDisposable} = require 'atom'

module.exports =
  lineEndingConverter: null
  subscriptions: null

  activate: (state) ->
    @lineEndingConverter = new LineEndingConverter()

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'line-ending-converter:convert-to-unix-format',
      => @lineEndingConverter.convertToUnixFormat()
    @subscriptions.add atom.commands.add 'atom-workspace',
      'line-ending-converter:convert-to-windows-format',
      => @lineEndingConverter.convertToWindowsFormat()
    @subscriptions.add atom.commands.add 'atom-workspace',
      'line-ending-converter:convert-to-old-mac-format',
      => @lineEndingConverter.convertToOldMacFormat()

  deactivate: ->
    @subscriptions.dispose()
    @subscriptions = null
    @lineEndingConverter = null
