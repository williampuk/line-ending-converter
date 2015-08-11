{SelectListView} = require 'atom-space-pen-views'

ITEMS = [
  { format:'\n', display: 'Unix (LF)', command: 'line-ending-converter:convert-to-unix-format' },
  { format:'\r\n', display: 'Windows (CRLF)', command: 'line-ending-converter:convert-to-windows-format' },
  { format:'\r', display: 'Old Mac (CR)', command: 'line-ending-converter:convert-to-old-mac-format' }
]

module.exports =
class LineEndingConverterListView extends SelectListView
  initialize: ->
    super()
    @addClass('eol-selector')
    @list.addClass('mark-active')
    @setItems(ITEMS)

  destroy: ->
    @panel?.destroy()
    @panel = null
    @editor = null
    @currentEol = null

  getFilterKey: ->
    'display'

  cancelled: ->
    @hide()

  confirmed: ({command}) ->
    atom.commands.dispatch(atom.views.getView(@editor), command)
    @cancel()

  toggle: ->
    if @panel?.isVisible()
      @cancel()
    else if @editor = atom.workspace.getActiveTextEditor()
      @currentEol = @editor.getBuffer()?.lineEndingForRow(0)
      @show()

  viewForItem: (eolItem) ->
    element = document.createElement('li')
    element.classList.add('active') if eolItem.format is @currentEol
    element.textContent = eolItem.display
    element.dataset.command = eolItem.command
    element

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @populateList()
    @panel.show()
    @storeFocusedElement()
    @focusFilterEditor()

  hide: ->
    @panel?.hide()
