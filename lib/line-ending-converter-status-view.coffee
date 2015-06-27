{CompositeDisposable,Disposable} = require 'atom'

# EOL status view in the status Bar
class LineEndingConverterStatusView extends HTMLDivElement
  [@WINDOWS_FORMAT, @UNIX_FORMAT, @OLD_MAC_FORMAT] = ['\r\n', '\n', '\r']

  [@WIN_TEXT, @UNIX_TEXT, @OLD_MAC_TEXT] = ['Win(CRLF)', 'Unix(LF)', 'Old Mac(CR)']
  #Default is '\n'. Solely by observation and subject to change. Need docs to support this.
  @DEFAULT_EOL_TEXT: @UNIX_TEXT

  initialize: (@statusBar) ->
    @classList.add('eol-status', 'inline-block')
    @eolLink = document.createElement('a')
    @eolLink.href = '#'
    @appendChild(@eolLink)
    @subscriptions = new CompositeDisposable
    @initSubscriptions()
    this

  attach: ->
    @tile?.destroy()
    if atom.config.get 'line-ending-converter.showOnStatusBar'
      @tile = @statusBar.addRightTile(item: this, priority: 12)

  initSubscriptions: ->
    activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()
    isShowConfigSubscription = atom.config.observe 'line-ending-converter.showOnStatusBar', =>
      @attach()
    @subscriptions.add activeItemSubscription
    @subscriptions.add isShowConfigSubscription

    @subscribeToActiveTextEditor()
    return

  destroy: ->
    @subscriptions?.dispose()
    @subscriptions = null
    @eolSubscription = null
    @tile?.destroy()
    @tile = null

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    @eolSubscription?.dispose()
    @subscriptions.remove @eolSubscription
    # Set new subscription to the active Text Editor
    @eolSubscription = @getActiveTextEditor()?.onDidStopChanging =>
      @setCurrentEolText()
    @subscriptions.add @eolSubscription
    @setCurrentEolText()
    return

  setCurrentEolText: ->
    buffer = @getActiveTextEditor()?.getBuffer()
    eolText = @getEolText(buffer?.lineEndingForRow(0))
    console.log 'line ending: ' + eolText, @style
    if eolText?
      @eolLink.textContent = eolText
      @style.display = ''
    else
      @eolLink.textContent = ''
      @style.display = 'none'

  getEolText: (eol) ->
    constructor = LineEndingConverterStatusView
    switch eol
      when constructor.UNIX_FORMAT then constructor.UNIX_TEXT
      when constructor.WINDOWS_FORMAT then constructor.WIN_TEXT
      when constructor.OLD_MAC_FORMAT then constructor.OLD_MAC_TEXT
      when '' then constructor.DEFAULT_EOL_TEXT
      else undefined

module.exports = document.registerElement('line-ending-converter-status', prototype: LineEndingConverterStatusView.prototype)
