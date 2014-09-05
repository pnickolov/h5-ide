
define [ "ApiRequest", "ApiRequestDefs", "UI.modalplus", "vender/select2/select2", "UI.modal" ], ( ApiRequest, ApiRequestDefs, Modal )->

  tmpl = """
<div id="DebugTool" class="debugToolBg"><ul>
<li id="DtDiff" class="icon-toolbar-diff tooltip" data-tooltip="Json Diff"></li>
<li id="DtView" class="icon-toolbar-cloudformation tooltip" data-tooltip="Json View"></li>
<li id="DtApi" class="tooltip debugToolBg" data-tooltip="Debug Api"></li>
<li id="DtSession" class="icon-user tooltip" data-tooltip="Share Session"></li>
<li id="DtClearStack" class="icon-delete tooltip" data-tooltip="Clear Stacks"></li>
<li id="DtClearApp" class="icon-terminate tooltip" data-tooltip="Terminate Apps"></li>
</ul>
<div id="DebugTooltip">console输入man查看快捷debug</div>
</div>
"""

  ApiDialog = """
<div class="modal-header"> <h3>Api Debugger</h3> <i class="modal-close">×</i> </div>
<div id="diffWrap"><div id="ApiDebugger">
<button class="btn btn-blue" id="ApiDebugSend">Send Request</button>
<section><label>Api : </label><select id="ApiSelect" data-placeholder="Select an api"></select></section>
<section><label>Parameters :</label><section id="ApiParamsWrap" class="clearfix"></section></section>
<section><label>Result :</label><pre id="ApiResult"></pre></section>
</div></div>
  """

  SessionDialog = """
<div class="modal-header"> <h3>Share Session</h3> <i class="modal-close">×</i> </div>
<div class="modal-body" style="width:500px">
  <h5>Paste & run this code to share session.</h5>
  <textarea id="DebugShareSession" spellcheck="false"></textarea>
</div>"""

  DebugTool = ()->
    $("head").append('<link rel="stylesheet" href="/assets/css/debugger.css"></link>')
    $(tmpl).appendTo("body")
    $("#DebugTool").on "click", "li", dispatchClick

  dispatchClick = ( evt )->
    id = evt.currentTarget.id
    switch id
      when "DtDiff" then dd.diff()
      when "DtView" then dd.view()
      when "DtApi"  then debugApi()
      when "DtSession" then debugSession()
      when "DtClearApp" then clearApp()
      when "DtClearStack" then clearStack()

  clearStack = ()->
    m = new Modal {
      title     : "删除所有Stack"
      template  : "你确定要删除所有的Stack吗？是所有哦！！！！！！"
      onConfirm : ()->
        App.model.stackList().models.slice(0).forEach ( m )-> m.remove()
        m.close()
    }

  clearApp = ()->
    m = new Modal {
      title     : "一键删除所有App"
      template  : "删除APP？删除APP？删除APP？删除APP？删除APP？删除APP？删除APP？删除APP？删除APP？删除APP？"
      onConfirm : ()->
        App.model.appList().models.slice(0).forEach ( m )-> m.terminate()
        m.close()
    }

  debugApi = ()->
    modal ApiDialog

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

    $("#ApiSelect").html(option).select2({width:400}).on "change", ()->
      val = $("#ApiSelect").select2("val")
      apiDef = ApiRequestDefs.Defs[ val ]
      $("#ApiResult").empty()
      $("#ApiSelect").siblings("label").text "Api : '#{val}'"
      if not apiDef then return $("#ApiParamsWrap").empty()
      phtml = ""
      for p in apiDef.params
        v = ApiRequestDefs.AutoFill(p)
        if v is null then v = ""
        phtml += "<input placeholder='#{p}' class='diffInput tooltip' value='#{v}' data-tooltip='#{p}'/>"
      $("#ApiParamsWrap").html phtml

    $("#ApiDebugSend").click ()->
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

      ApiRequest( api, params ).then ( result )->

        data = result
        if data.length < 2
          notification "warn", "AppService return data is not correct"
        else
          if apiDef.url.indexOf("/aws/") is 0 and apiDef.url.length > 5 and (typeof data[1] is "string")
            #return is xml
            try
              data[1] = $.xml2json ($.parseXML data[1])
            catch
          else if apiDef.url.indexOf("/os/") is 0
            if apiDef.method is "Info"
              for item,idx in data
                try
                  data[idx][1] = JSON.parse(item[1])
                catch
            else
              #return is json
              try
                data[1] = JSON.parse(data[1])
              catch


        $("#ApiResult").text JSON.stringify( data, undefined, 4 )
        $("#ApiDebugSend").removeAttr("disabled")
        $("#ApiResult").attr("finish","true")
      , ( error )->
        $("#ApiResult").text JSON.stringify( error, undefined, 4 )
        $("#ApiDebugSend").removeAttr("disabled")
        $("#ApiResult").attr("finish","true")
      null



    $("#modal-box").css({
      width  : "98%"
      height : "98%"
      top    : "1%"
      left   : "1%"
    })

    $("#ApiSelect").select2("open")
    $("#s2id_autogen1_search").focus()


  debugSession = ()->
    session = "(function(){var o = {expires:30,path:'/'}, a = #{JSON.stringify($.cookie())},k;for (k in a) { $.cookie(k,a[k],o); } window.location.href = window.location.protocol + '//' + window.location.host + '#{window.location.pathname}'; })();"

    modal SessionDialog
    $("#DebugShareSession").html(session).select()
    return

  DebugTool
