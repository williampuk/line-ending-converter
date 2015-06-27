{CompositeDisposable} = require 'atom'

module.exports =
  lineEndingConverter: null
  subscriptions: null
  config:
    showOnStatusBar:
      type: 'boolean'
      default: true
  activate: (state) ->
    LineEndingConverter = require './line-ending-converter'
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
    @subscriptions?.dispose()
    @subscriptions = null
    @lineEndingConverterStatusView?.destroy()
    @lineEndingConverterStatusView = null

    @lineEndingConverter = null

  consumeStatusBar: (statusBar) ->
    LineEndingConverterStatusView = require './line-ending-converter-status-view'
    @lineEndingConverterStatusView =
      new LineEndingConverterStatusView().initialize(statusBar)
    @lineEndingConverterStatusView.attach()
