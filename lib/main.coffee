{CompositeDisposable} = require 'atom'

module.exports =
  lineEndingConverter: null
  subscriptions: null
  config:
    showEolInStatusBar:
      title: 'Show File EOL In Status Bar'
      description: 'Show in the status bar the EOL type of the first row of the file.'
      type: 'boolean'
      default: true
    normalizeEolOnSave:
      title: "(Experimental!) Normalize File EOL's On Save"
      type: 'string'
      default: 'Disabled'
      enum: ['Disabled', "Auto Detect (Use First Row's EOL)", 'Win (CRLF)', 'Unix (LF)', 'Old Mac (CR)']

  activate: (state) ->
    LineEndingConverter = require './line-ending-converter'
    @lineEndingConverter = new LineEndingConverter()

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-text-editor',
      'line-ending-converter:convert-to-unix-format',
      => @lineEndingConverter.convertToUnixFormat()
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'line-ending-converter:convert-to-windows-format',
      => @lineEndingConverter.convertToWindowsFormat()
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'line-ending-converter:convert-to-old-mac-format',
      => @lineEndingConverter.convertToOldMacFormat()

    @subscriptions.add atom.commands.add 'atom-text-editor',
      'line-ending-converter-list-view:show',
      => @createListView()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

    @lineEndingConverterStatusView?.destroy()
    @lineEndingConverterStatusView = null

    @lineEndingConverter?.destroy()
    @lineEndingConverter = null

    @lineEndingConverterListView?.destroy()
    @lineEndingConverterListView = null

  consumeStatusBar: (statusBar) ->
    LineEndingConverterStatusView = require './line-ending-converter-status-view'
    @lineEndingConverterStatusView = new LineEndingConverterStatusView().initialize(statusBar)
    @lineEndingConverterStatusView.attach()

  createListView: ->
    unless @lineEndingConverterListView?
      LineEndingConverterListView = require './line-ending-converter-list-view'
      @lineEndingConverterListView = new LineEndingConverterListView()
    @lineEndingConverterListView.toggle()
