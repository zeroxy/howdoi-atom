# howdoi-atom package

아톰 플러그인 개발 의 입문자의 입문기를 기반으로 한 입문서

-----

*__[Atom - Your first package](https://atom.io/docs/v0.172.0/your-first-package)__를 기반으로 작성된 페이지 입니다. *

# 나도 간지나는 플러그 인이 만들고 싶다.

![개발자들이 다들 격는 문제점](https://camo.githubusercontent.com/a88cefeb7431526ae025ce453d8efd95b3b3fa20/687474703a2f2f696d67732e786b63642e636f6d2f636f6d6963732f7461722e706e67)

[How do i](https://github.com/gleitz/howdoi)라는 툴이 있다.

python 기반으로 작성된 이 커맨드 라인 기반으로 stackoverflow 의 답변을 검색해 오는 툴이다.

이 툴을 기반으로 Vim 의 플러그인 [Vim-Howdoi](https://github.com/laurentgoudet/vim-howdoi) 가 나왔다.

![Vim-Howdoi 화면](https://camo.githubusercontent.com/954aa47a43faea0993ca998a5838c1a5e0546d3a/68747470733a2f2f7261772e6769746875622e636f6d2f6c617572656e74676f756465742f76696d2d686f77646f692f6d61737465722f76696d2d686f77646f692e676966)

이런식으로 사용 하는 툴이다.

우리는 Atom editor 를 위한 Atom-howdoi 를 만들어 보도록 하겠다.


# Atom plugin 작성

### package template 생성
Atom 을 실행 후 ``` Ctrl + Shift + P ``` 키를 눌러 Command Palette 를 실행한다.

"generate package" 를 타입하면 나오는 **"Package Generator: Generate Package"** 명령을 실행!!

플러그 인의 이름과 Path를 묻는데, 이때 이름에 atom- 이라는 접두사는 피하도록 한다.

여기서 나는 howdoi-atom 으로 이름을 작성하였다.

기본 템플릿을 생성한다.

기본적으로 생성된 템플릿을 검증하기 위해 다시 Command Palette ``` Ctrl + Shift + P ``` 에서

방금 생성한 howdoi-atom 을 타입하면 "howdoi-atom: Toggle" 이 나오고, 실행시 팝업 메세지가 나타난다.


### 스크립트 작성

``` lib/howdoi-atom.coffee ``` 파일을 열어 아래와 같은 코드만 남기고 다 삭제한다.

```coffeescript
module.exports =
  activate: ->
```

이제 간단한 메세지를 추가해주는 명령을 먼저 작성해보자.

```coffeescript
module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', "howdoi-atom:convert", => @convert()

    convert: ->
      # This assumes the active pane item is an editor
      editor = atom.workspace.getActivePaneItem()
      editor.insertText('Hello, World!')
```

위와 같은 코드를 작성후 atom 을 reload 해야 플러그인이 불러진다.

``` Ctrl + Shift + R ``` 로 아톰을 새로 불러오자.

### 그래봤자 Command Palette 에서는 불러지지 않고....

Command Palette ``` Ctrl + Shift + P ``` 에서 convert를 쳐도 나오지 않을것이다.

```package.json``` 이라는 파일을 열어서 convert 라는 명령이 있음을 명시하자.

기존 명령들이 기록되 있는 부분을 지우고... 아래와 같이 작성한다.

```json
"activationEvents": [ "howdoi-atom:convert"]
```

activationEvents 에 등록하는 것은 atom 의 시작시 로드 할 모듈을 뒤로 미뤄줘 실행시간을 단축시켜준다.

이왕한김에 맨날 Command Palette 열어서 실행해보는게 귀찮다.

단축키로도 등록하자.

```keymaps/howdoi-atom.cson``` 파일을 열자.

```cson
'atom-text-editor':
  'ctrl-alt-a': 'howdoi-atom:convert'
```

저장후 다시 한번 Reload! ``` Ctrl + Shift + R ```

이제 ``` Ctrl + Alt + A ``` 로 **Hello, World!** 를 손쉽게 찍어 볼 수 있게 되었다.

축하한다. 헬로월드를 아주 빠르게 칠수있는 프로그래머가 되었다.

### 이제 본격적으로 기능을 구현해보자.

nodejs 기반이다 보니 기본 package인 http 를 불러서 이용 할 수 있다.

하지만 일일이 http client 를 구현하고, html parsing을 하는 건 선각자의 노력을 무시하는 것!

우리는 [Request](https://github.com/request/request) 라는 모듈과
[Cheerio](https://github.com/cheeriojs/cheerio) 라는 모듈을 이용하기로 하자.

모듈 설치 원리는 apm 모듈을 이용해 npm repository 에서 불러오는것 같다.(아직 확인해보진 않음)

다시 ```package.json``` 이라는 파일을 열어서 아래와 같이 작성한다.

```json
"dependencies": {
  "request": "2.51.0",
  "cheerio": "0.18.0"
}
```

저장 후 Command Palette ``` Ctrl + Shift + P ``` 에서 "update-package-dependencies:update" 를 수행!

재시작 없이 모듈 업데이트가 실행된다.

모듈이 설치 됏으니 본격적으로 실제 동작 스크립트를 작성하자.

```coffeescript
module.exports =
  activate: ->
    atom.commands.add 'atom-workspace', "howdoi-atom:convert", => @convert()

    convert: ->
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

```

자세한 설명은 생랴칸다. 나도 coffee 스크립트 처음 써봄..

# 리빙 포인트!!

*``` Ctrl + Shift + I ```로 우리에게 익숙한 크롬 개발자 콘솔을 열 수 있다.*
