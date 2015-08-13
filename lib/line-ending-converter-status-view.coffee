{Disposable} = require 'atom'

[WINDOWS_FORMAT, UNIX_FORMAT, OLD_MAC_FORMAT] = ['\r\n', '\n', '\r']
[WIN_TEXT, UNIX_TEXT, OLD_MAC_TEXT] = ['CRLF', 'LF', 'CR']
#Default is '\n'. Solely by observation and subject to change. Need docs to support this.
DEFAULT_TEXT = UNIX_TEXT
# EOL status view in the status Bar
class LineEndingConverterStatusView extends HTMLDivElement
  initialize: (@statusBar) ->
    @classList.add('eol-status', 'inline-block')
    @eolLink = document.createElement('a')
    @eolLink.href = '#'
    @appendChild(@eolLink)
    @initConfigSubscriptions()
    this

  destroy: ->
    @disposeViewSubscriptions()
    @showConfigSubscription?.dispose()
    @showConfigSubscription = null
    @tile?.destroy()
    @tile = null
    return

  initConfigSubscriptions: ->
    @showConfigSubscription =
      atom.config.onDidChange 'line-ending-converter.showEolInStatusBar', () => @attach()

  attach: ->
    @tile?.destroy()
    if atom.config.get 'line-ending-converter.showEolInStatusBar'
      @initViewSubscriptions()
      @tile = @statusBar.addRightTile(item: this, priority: 12)
    else
      @disposeViewSubscriptions()
    @tile

  disposeViewSubscriptions: ->
    @activeItemSubscription?.dispose()
    @activeItemSubscription = null
    @eolSubscription?.dispose()
    @eolSubscription = null
    @clickSubscription?.dispose()
    @clickSubscription = null
    return

  initViewSubscriptions: ->
    @disposeViewSubscriptions()
    @activeItemSubscription =
      atom.workspace.onDidChangeActivePaneItem(=> @subscribeToActiveTextEditor())

    clickHandler =
      => atom.commands.dispatch(atom.views.getView(@getActiveTextEditor()), 'line-ending-converter-list-view:show')
    @addEventListener 'click', clickHandler
    @clickSubscription = new Disposable(=> @removeEventListener('click', clickHandler))

    @subscribeToActiveTextEditor()
    return

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    @eolSubscription?.dispose()
    # Set new subscription to the active Text Editor
    @eolSubscription = @getActiveTextEditor()?.onDidStopChanging =>
      @setCurrentEolText()
    @setCurrentEolText()
    return

  setCurrentEolText: ->
    buffer = @getActiveTextEditor()?.getBuffer()
    eolText = if buffer? then @getEolText(buffer.lineEndingForRow(0)) else undefined
    if eolText?
      @eolLink.textContent = eolText
      @eolLink.dataset.eol = eolText
      @style.display = ''
    else
      @eolLink.textContent = ''
      @eolLink.dataset.eol = ''
      @style.display = 'none'
    return

  getEolText: (eol) ->
    switch eol
      when UNIX_FORMAT then UNIX_TEXT
      when WINDOWS_FORMAT then WIN_TEXT
      when OLD_MAC_FORMAT then OLD_MAC_TEXT
      when '' then DEFAULT_TEXT
      else undefined

module.exports = document.registerElement('line-ending-converter-status', prototype: LineEndingConverterStatusView.prototype)
