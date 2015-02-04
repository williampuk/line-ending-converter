path = require 'path'
fs = require 'fs'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

# Below expectations are commented out due to these expectations may not pass after uploading to git.

describe "LineEndingConverter", ->
  [workspace, workspaceView, activationPromise] = []

  beforeEach ->
    workspace = atom.workspace
    workspaceView = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage 'line-ending-converter'

  describe "when the line-ending-converter:convert-to-unix-format event is triggered", ->
    it "should convert all the line endings to unix format", ->
      [beforeFileEditor, beforeFileEditorView, beforeText] = []
      resultText = fs.readFileSync path.join(__dirname, './fixtures/convert-to-unix/after.txt'), 'utf8'
      console.log resultText

      waitsForPromise ->
        activationPromise.then ->
          workspace.open(path.join __dirname, './fixtures/convert-to-unix/before.txt')
          .then (editor) ->
            beforeFileEditor = editor
            beforeFileEditorView = atom.views.getView(beforeFileEditor)
            beforeText = beforeFileEditor.getBuffer().getText()
            atom.commands.dispatch workspaceView,
              'line-ending-converter:convert-to-unix-format'

      runs ->
        # expect(beforeText.match /\r\n|\r/g).not.toBe null
        # expect(beforeFileEditor.getBuffer().getText()).toBe resultText
        expect(beforeFileEditor.getBuffer().getText().match /\r\n|\r/g).toBe null

  describe "when the line-ending-converter:convert-to-windows-format event is triggered", ->
    it "should convert all the line endings to windows format", ->
      [beforeFileEditor, beforeFileEditorView, beforeText] = []
      resultText = fs.readFileSync path.join(__dirname, './fixtures/convert-to-windows/after.txt'), 'utf8'
      console.log resultText

      waitsForPromise ->
        activationPromise.then ->
          workspace.open(path.join __dirname, './fixtures/convert-to-windows/before.txt')
          .then (editor) ->
            beforeFileEditor = editor
            beforeFileEditorView = atom.views.getView(beforeFileEditor)
            beforeText = beforeFileEditor.getBuffer().getText()
            atom.commands.dispatch workspaceView,
              'line-ending-converter:convert-to-windows-format'

      runs ->
        # expect(beforeFileEditor.getBuffer().getText()).toBe resultText
        expect(beforeFileEditor.getBuffer().getText().match(/\r\n/g).length).toBe 17

  describe "when the line-ending-converter:convert-to-old-mac-format event is triggered", ->
    it "should convert all the line endings to old Mac format", ->
      [beforeFileEditor, beforeFileEditorView, beforeText] = []
      resultText = fs.readFileSync path.join(__dirname, './fixtures/convert-to-old-mac/after.txt'), 'utf8'
      console.log resultText

      waitsForPromise ->
        activationPromise.then ->
          workspace.open(path.join __dirname, './fixtures/convert-to-old-mac/before.txt')
          .then (editor) ->
            beforeFileEditor = editor
            beforeFileEditorView = atom.views.getView(beforeFileEditor)
            beforeText = beforeFileEditor.getBuffer().getText()
            atom.commands.dispatch workspaceView,
              'line-ending-converter:convert-to-old-mac-format'

      runs ->
        # expect(beforeText.match /\r\n|\n/g).not.toBe null
        # expect(beforeFileEditor.getBuffer().getText()).toBe resultText
        expect(beforeFileEditor.getBuffer().getText().match /\r\n|\n/g).toBe null
