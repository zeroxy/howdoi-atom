module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', "howdoi-atom:convert", => @convert()
    atom.commands.add 'atom-workspace', "howdoi-atom:stock", => @stock()
    atom.commands.add 'atom-workspace', "howdoi-atom:howdoi", => @howdoi()

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
        selection.insertText("#{asciiArt}\n\nzeroxy")

  stock: ->
    editor = atom.workspace.getActivePaneItem()
    selection = editor.getLastSelection()
    console.log("getStock!!!")
    path = "http://polling.finance.naver.com/api/realtime.nhn?query=SERVICE_ITEM:018260"
    request = require 'request'
    request path, (error, response, body) ->
      if !error && response.statusCode == 200
        stockdata = JSON.parse(body).result.areas[0].datas[0]
        selection.insertText("우리회사 현재 / 어제 : #{stockdata.nv} / #{stockdata.pcv}(원)")

  howdoi: ->
    editor = atom.workspace.getActivePaneItem()
    selection = editor.getLastSelection()
    file_name_and_extend = atom.workspace.getActiveEditor().getTitle().split(".")
    file_extend = unless file_name_and_extend.length == 1 then file_name_and_extend[file_name_and_extend.length-1] else ""
    path = "http://www.google.co.kr/search?q=site:stackoverflow.com%20#{selection.getText()}" #"%20#{file_extend}"
    console.log("How Do I ????", selection.getText(), file_name_and_extend,"\n\n",path)
    request = require 'request'
    cheerio = require 'cheerio'
    request path, (error, response, body) ->
      if !error && response.statusCode == 200
        link_list = cheerio.load(body)('h3 a').map (i, el) ->
          if el.attribs.href.indexOf('http://stackoverflow.com/questions/') >= 0
            q_end = el.attribs.href.indexOf('&')
            console.log(i, el.attribs.href.substring(7,q_end))
            return el.attribs.href.substring(7,q_end)+"?answertab=votes"
        console.log link_list[0]
        request link_list[0], (err, res, body) ->
          first_answer = cheerio.load(body)('.answer').eq(0)
          result = first_answer.find('pre').text()
          console.log(result)
          if result
            selection.insertText("#{selection.getText()}\n#{result}")
          else
            result = first_answer.find('.post-text').text()
            selection.insertText("#{selection.getText()}\n#{result}\n---\nAnswer from #{link_list[0]}")
