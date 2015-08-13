{$} = require 'atom-space-pen-views'

ITEMS = [
  { format:'\n', display: 'Unix (LF)', command: 'line-ending-converter:convert-to-unix-format' },
  { format:'\r\n', display: 'Windows (CRLF)', command: 'line-ending-converter:convert-to-windows-format' },
  { format:'\r', display: 'Old Mac (CR)', command: 'line-ending-converter:convert-to-old-mac-format' }
]

describe "Line Ending Converter List View", ->
  [workspaceView, editor, editorView] = []

  beforeEach ->
    workspaceView = atom.views.getView atom.workspace
    jasmine.attachToDOM workspaceView

    waitsForPromise ->
      atom.packages.activatePackage 'status-bar'

    waitsForPromise ->
      atom.packages.activatePackage 'line-ending-converter'

    waitsForPromise ->
      atom.workspace.open 'unix.txt'

    runs ->
      editor = atom.workspace.getActiveTextEditor()
      editorView = atom.views.getView editor

  describe "when line-ending-converter-list-view:show is triggered", ->
    it "displays a list of all line endings", ->
      atom.commands.dispatch(editorView, 'line-ending-converter-list-view:show')
      listView = atom.workspace.getModalPanels()[0].getItem()
      expect(listView.list.children('li').length).toBe ITEMS.length
      for i in [0...ITEMS.length]
        expect(listView.list.children('li').eq(i).text()).toBe ITEMS[i].display
        expect(listView.list.children('li').eq(i).data('command')).toBe ITEMS[i].command

  describe "when a eol is selected", ->
    it "emits a call of the corresponding conversion command", ->
      for i in [0...ITEMS.length]
        do () ->
          atom.commands.dispatch(editorView, 'line-ending-converter-list-view:show')
          listView = atom.workspace.getModalPanels()[0].getItem()
          eventHandler = jasmine.createSpy('eventHandler')
          atom.commands.add editorView, ITEMS[i].command, eventHandler
          listView.confirmed ITEMS[i]
          expect(eventHandler).toHaveBeenCalled()
      return

  describe "when the editor's first line eol is UNIX", ->
    it "displays 'Unix (LF)' as the selected eol", ->
      atom.commands.dispatch(editorView, 'line-ending-converter-list-view:show')
      listView = atom.workspace.getModalPanels()[0].getItem()
      expect(listView.list.children('li.active').length).toBe 1
      expect(listView.list.children('li.active').text()).toBe ITEMS[0].display

  describe "when the editor's first line eol is WINDOWS", ->
    it "displays 'Windows (CRLF)' as the selected eol", ->
      editor.setText 'abc\r\ndef\nghi\rjkl'
      atom.commands.dispatch(editorView, 'line-ending-converter-list-view:show')
      listView = atom.workspace.getModalPanels()[0].getItem()
      expect(listView.list.children('li.active').length).toBe 1
      expect(listView.list.children('li.active').text()).toBe ITEMS[1].display

  describe "when the editor's first line eol is OLD_MAC", ->
    it "displays 'Old Mac (CR)' as the selected eol", ->
      editor.setText 'abc\rdef\r\nghi\njkl'
      atom.commands.dispatch(editorView, 'line-ending-converter-list-view:show')
      listView = atom.workspace.getModalPanels()[0].getItem()
      expect(listView.list.children('li.active').length).toBe 1
      expect(listView.list.children('li.active').text()).toBe ITEMS[2].display
