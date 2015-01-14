module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', "howdoi-atom:convert", => @convert()

  convert: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.getActivePaneItem()
    selection = editor.getLastSelection()

    figlet = require 'figlet'
    console.log(selection.getText())
    figlet selection.getText(), {font: "Larry 3d 2"}, (error, asciiArt) ->
      if error
        console.error(error)
      else
        selection.insertText("#{asciiArt}")
