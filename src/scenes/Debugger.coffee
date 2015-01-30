

define [
  "Scene",
  "./DebuggerTpl"
  "ApiRequest"
  "ApiRequestOs"
  "ApiRequestDefs"
  "Design"
  "component/jsonviewer/JsonViewer"
  "backbone"
  "jquery"
  "UI.select2"
  "UI.tooltip"
], ( Scene, Template, ApiRequest, ApiRequestOs, ApiRequestDefs, Design, JsonViewer )->

  window.d   = ()-> Design.instance()
  window.dds = ()-> debug.designSerialize()

  window.debug = {
    stacks : ()->
      s = {}
      for p in App.model.projects().models
        s[p.id] = {
          name   : p.get("name")
          stacks : []
        }
        for m in p.stacks().models
          s[p.id].stacks.push m
      s

    apps : ()->
      s = {}
      for p in App.model.projects().models
        s[p.id] = {
          name : p.get("name")
          apps : []
        }
        for m in p.apps().models
          s[p.id].apps.push m
      s

    selectedComp : ()->
      s = App.sceneManager.activeScene()
      if s.getAwakeSpace
        s = s.getAwakeSpace()
        if s.getSelectedComponent
          return s.getSelectedComponent()
      null

    selectedCompState : ()->
      comp = debug.selectedComp()?.serialize()[1]
      if comp and comp.component and comp.component.state
        '{\n\t"component": {\n\t\t"init" : {\n\t\t\t"state": ' + JSON.stringify(comp.component.state) + '\n\t\t}\n\t}\n}\n'
      else
        "no state for selected component"

    designSerialize : ()->
      if not Design.instance() then return

      data = Design.instance().serialize()
      console.log( data )
      return JSON.stringify( data )

    designCheckValid : ()->
      Design.instance().eachComponent ( comp )->
        if comp.design() is Design.instance()
          console.log "Valid design"
        else
          console.log "Invalid design"
        null
      null

    designExportToFile : ()->
      if not Design.instance() then return

      filename = 'CanvasData.json'
      data     = Design.debug.json()

      blob = new Blob([data], {type: 'text/json'})
      e    = document.createEvent('MouseEvents')
      a    = document.createElement('a')

      a.download = filename
      a.href = window.URL.createObjectURL(blob)
      a.dataset.downloadurl =  ['text/json', a.download, a.href].join(':')
      e.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
      a.dispatchEvent(e)
      null

    designDiff : ()->
      if Design.instance()
        JsonViewer.showDiffDialog( Design.instance().__opsModel.getJsonData(), Design.instance().serialize() )
      return

    designView : ()->
      if not Design.instance() then return
      JsonViewer.showViewDialog( Design.instance().serialize() )
      return

    designLayout : ()-> App.workspaces.getAwakeSpace().view.canvas.autoLayout()

    designSet : ( a, b )-> Design.instance()?.set(a,b)
    designGet : ( a )->    Design.instance()?.get(a)

    designComps : ()->
      if not Design.instance() then return

      checkedMap   = {
        "line"            : {}
        "node"            : {}
        "group"           : {}
        "otherResource"   : {}
        "otherConnection" : {}
      }
      for id, a of Design.instance().__componentMap
        if a.node_group
          checkedMap.group[ a.id ] = a
        else if a.node_line
          if a.isVisual()
            checkedMap.line[ a.id ] = a
          else
            checkedMap.otherConnection[ a.id ] = a
        else
          if a.isVisual()
            checkedMap.node[ a.id ] = a
          else
            checkedMap.otherResource[ a.id ] = a

      checkedMap
  }

  window.man = "
  d()          Return the current Design instance \n
  dds()        Print JSON \n
  copy(dds())  Copy JSON
  debug        A object contains some debug functions.
  "
  null


  # App.Debugger
  AppDebugger = Backbone.View.extend {

    events :
      "click li" : ( evt )-> @[ evt.currentTarget.id ]?()

    initialize : ()->
      $("head").append('<link rel="stylesheet" href="/assets/css/debugger.css"></link>')
      @setElement $( Template.Toolbar() ).appendTo( "body" )
      return

    ask : ( content, buttons )->
      q = $( Template.Question({ content:content, buttons:buttons||[] }) ).prependTo( "body" )
      self = @
      q.on "click", "button", ( evt )->
        self[ $( evt.currentTarget ).attr("data-id") ]?()

      setTimeout ()->
        $("#DebugQuestion").addClass("ready")
      , 18
      return

    DtDiff : ()-> debug.designDiff()

    DtView : ()-> debug.designView()

    DtApi  : ()-> new ApiDebugger()

    DtSession : ()->
      session = "<textarea id='DebugShareSession' spellcheck='false'>(function(){var o = {expires:30,path:'/'}, a = #{JSON.stringify($.cookie())},k;for (k in a) { $.cookie(k,a[k],o); } window.location.href = window.location.protocol + '//' + window.location.host + '#{window.location.pathname}'; })();</textarea>"

      @ask session
      setTimeout ()->
        $("#DebugShareSession").focus().select()
      , 200
      return

    DtClearApp : ()->
      buttons = [
        {
          id   : "debug_q_clear_project_app"
          text : "当前项目的App"
        }
        {
          id   : "debug_q_clear_all_app"
          text : "所有项目的App"
        }
      ]
      @ask "えええええええっ！！你要Teminate所有App？本当ですか？", buttons

    DtClearStack : ()->
      buttons = [
        {
          id   : "debug_q_clear_project_stack"
          text : "当前项目的Stack"
        }
        {
          id   : "debug_q_clear_all_stack"
          text : "所有项目的Stack"
        }
      ]
      @ask "マジですか？你要删除所有Stack？", buttons

    debug_q_close : ()->
      $("#DebugQuestion").addClass("quick").removeClass("ready")
      setTimeout ()->
        $("#DebugQuestion").remove()
      , 100
      return

    debug_q_clear_project_stack : ()->
      s = App.sceneManager.activeScene()
      if _.isFunction( s.project )
        p = s.project()
      else
        p = App.model.getPrivateProject()

      for m in p.stacks().models.slice(0)
        m.remove()
      @debug_q_close()

    debug_q_clear_project_app   : ()->
      s = App.sceneManager.activeScene()
      if _.isFunction( s.project )
        p = s.project()
      else
        p = App.model.getPrivateProject()

      for m in p.apps().models.slice(0)
        m.remove()
      @debug_q_close()

    debug_q_clear_all_stack : ()->
      for p in App.model.projects().models
        for m in p.stacks().models.slice(0)
          m.remove()
      @debug_q_close()

    debug_q_clear_all_app   : ()->
      for p in App.model.projects().models
        for m in p.apps().models.slice(0)
          m.terminate()
      @debug_q_close()

  }

  ApiDebuggerView = Backbone.View.extend {

    events :
      "change #ApiSelect"        : "onApiChange"
      "click  #ApiDebugSend"     : "onSendClick"
      "click  #ApiDebuggerClose" : "close"

    initialize : ()->
      @setElement $(Template.ApiDebugger()).appendTo("body")
      @render()

      $("#ApiSelect").select2("open")
      $("#s2id_autogen1_search").focus()
      return

    remove : ()->
      $("#ApiSelect").select2("destroy")
      @$el.remove()

    close : ()-> @trigger "closed"

    render : ()->
      option = "<option></option>"
      group  = {}

      for defName, def of ApiRequestDefs.Defs
        d = defName.split "_"
        if d.length == 1
          g = "General"
        else
          g = d[0].toUpperCase()
        if not group[g] then group[g] = []
        group[g].push defName

      for groupName, g of group
        option += "<optgroup label='#{groupName}'>"
        for gg in g
          option += "<option value='#{gg}'>#{gg}</option>"
        option += "</optgrouop>"

      $("#ApiSelect").html(option).select2({
        dropdownCssClass:"debugger"
        matcher:(term, text, opt)-> text.match(new RegExp(term.replace(/\s+/g, '').split('').join('.*'), 'i'))
      })

    onApiChange : ()->
      val = $("#ApiSelect").select2("val")
      apiDef = ApiRequestDefs.Defs[ val ]
      $("#ApiResult").empty()
      $("#ApiDebuggerLabel").text "Api : '#{val}'"
      if not apiDef then return $("#ApiParamsWrap").empty()
      phtml = ""
      for p in apiDef.params
        v = ApiRequestDefs.AutoFill(p)
        if v is null then v = ""
        phtml += "<input placeholder='#{p}' class='tooltip' value='#{v}' data-tooltip='#{p}'/>"
      $("#ApiParamsWrap").html phtml

      @trigger "apiChanged", val

    onSendClick : ()->
      api = $("#ApiSelect").select2("val")
      apiDef = ApiRequestDefs.Defs[ api ]
      if not apiDef then return
      params = {}
      for ch in $("#ApiParamsWrap").children("input")
        v = ch.value
        if not v then continue
        k = $(ch).attr("placeholder")
        try
          params[k] = JSON.parse v
        catch e
          params[k] = v

      $("#ApiDebugSend").attr("disabled", "disabled")
      $("#ApiResult").text("Loading...").attr("finish","false")

      (if apiDef.type is "openstack" then ApiRequestOs else ApiRequest)( api, params ).then ( result )->

        if apiDef.url.indexOf("/aws/") is 0 and apiDef.url.length > 5 and (typeof result[1] is "string")
          #return is xml
          try
            result[1] = $.xml2json ($.parseXML result[1])
          catch
        else if apiDef.url.indexOf("/os/") is 0
          if apiDef.method is "Info"
            for item,idx in result
              try
                if $.type(result) is 'array'
                  for c,i in item
                    result[idx][i] = JSON.parse(c)
                else
                  result[idx] = JSON.parse(item)
              catch
          else
            #return is json
            try
              result[1] = JSON.parse(result[1])
            catch


        $("#ApiResult").text JSON.stringify( result, undefined, 4 )
        $("#ApiDebugSend").removeAttr("disabled")
        $("#ApiResult").attr("finish","true")
      , ( error )->
        $("#ApiResult").text JSON.stringify( error, undefined, 4 )
        $("#ApiDebugSend").removeAttr("disabled")
        $("#ApiResult").attr("finish","true")
      null

    switchToApi : ( api )->
      $("#ApiSelect").select2("val", api).select2("close")
      @onApiChange()
  }

  # DebuggerScene
  class ApiDebugger extends Scene

    api : ""

    constructor : ( api )->
      api = api || ""
      ss = App.sceneManager.find( "ApiDebugger" )
      if ss
        ss.activate()
        ss.switchToApi( api )
        return ss

      return Scene.call this, api

    initialize : ( api )->
      @view = new ApiDebuggerView()
      @listenTo @view, "apiChanged", @onApiChange
      @listenTo @view, "closed", @remove
      @activate()
      @switchToApi( api || "" )

    title : ()-> "API Debugger"
    url   : ()->
      if @api
        "debug/api/#{@api}"
      else
        "debug/api"

    isWorkingOn : ( attr )-> attr is "ApiDebugger"

    onApiChange : ( api )->
      @api = api
      @updateUrl()

    switchToApi : ( api )->
      if @api is api or not api then return
      @onApiChange()
      @view.switchToApi( api )

  new AppDebugger()

  window.Router.route "debug/api(/:theapi)", ( theapi )-> new ApiDebugger( theapi )

  return
