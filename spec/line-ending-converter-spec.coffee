path = require 'path'
fs = require 'fs'
# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Converting line endings", ->
  [editor, workspaceView, activationPromise] = []

  SAMPLE_TEXT = "a\nb\rc\r\nd\r\ne\rf\ng"
  TO_UNIX_RESULT = "a\nb\nc\nd\ne\nf\ng"
  TO_WINDOWS_RESULT = "a\r\nb\r\nc\r\nd\r\ne\r\nf\r\ng"
  TO_OLD_MAC_RESULT = "a\rb\rc\rd\re\rf\rg"

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()
    runs ->
      editor = atom.workspace.getActiveTextEditor()
      workspaceView = atom.views.getView(atom.workspace)
      activationPromise = atom.packages.activatePackage 'line-ending-converter'

  describe "when the line-ending-converter:convert-to-unix-format event is triggered", ->
    it "should convert all the line endings to Unix format", ->
      editor.setText SAMPLE_TEXT
      atom.commands.dispatch workspaceView,
        'line-ending-converter:convert-to-unix-format'

      waitsForPromise -> activationPromise

      runs ->
        expect(SAMPLE_TEXT.match /\r\n|\r\w/g).not.toBe null
        expect(editor.getText()).toBe TO_UNIX_RESULT
        expect(editor.getText().match /\r\n|\r\w/g).toBe null

  describe "when the line-ending-converter:convert-to-windows-format event is triggered", ->
    it "should convert all the line endings to Windows format", ->
      editor.setText SAMPLE_TEXT
      atom.commands.dispatch workspaceView,
        'line-ending-converter:convert-to-windows-format'

      waitsForPromise -> activationPromise

      runs ->
        expect(SAMPLE_TEXT.match /\w\n|\r\w/g).not.toBe null
        expect(editor.getText()).toBe TO_WINDOWS_RESULT
        expect(editor.getText().match /\w\n|\r\w/g).toBe null


  describe "when the line-ending-converter:convert-to-old-mac-format event is triggered", ->
    it "should convert all the line endings to old Mac format", ->
      editor.setText SAMPLE_TEXT
      atom.commands.dispatch workspaceView,
        'line-ending-converter:convert-to-old-mac-format'

      waitsForPromise -> activationPromise

      runs ->
        expect(SAMPLE_TEXT.match /\r\n|\w\n/g).not.toBe null
        expect(editor.getText()).toBe TO_OLD_MAC_RESULT
        expect(editor.getText().match /\r\n|\w\n/g).toBe null
