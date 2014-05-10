
define [ "ApiRequest", "ApiRequestDefs", "vender/select2/select2" ], ( ApiRequest, ApiRequestDefs )->

  tmpl = """
<div id="DebugTool" class="debugToolBg"><ul>
<li id="DtDiff" class="icon-toolbar-diff tooltip" data-tooltip="Json Diff"></li>
<li id="DtView" class="icon-toolbar-cloudformation tooltip" data-tooltip="Json View"></li>
<li id="DtApi" class="tooltip debugToolBg" data-tooltip="Debug Api"></li>
<li id="DtSession" class="icon-user tooltip" data-tooltip="Share Session"></li>
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

  DebugTool = ()->
    $("head").append('<link rel="stylesheet" href="./assets/css/debugger.css"></link>')
    $(tmpl).appendTo("body")
    $("#DebugTool").on "click", "li", dispatchClick

  dispatchClick = ( evt )->
    id = evt.currentTarget.id
    switch id
      when "DtDiff" then dd.diff()
      when "DtView" then dd.view()
      when "DtApi"  then debugApi()
      when "DtSession" then debugSession()

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
      apiDef = ApiRequestDefs.Defs[ $("#ApiSelect").select2("val") ]
      $("#ApiResult").empty()
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

      ApiRequest( api, params ).then ( result )->
        $("#ApiResult").text JSON.stringify( result, undefined, 4 )
      , ( error )->
        $("#ApiResult").text JSON.stringify( error, undefined, 4 )



    $("#modal-box").css({
      width  : "98%"
      height : "98%"
      top    : "1%"
      left   : "1%"
    })


  debugSession = ()->
    session = "(function(){var o = {expires:30,path:'/'}, a = #{JSON.stringify($.cookie())},k;for (k in a) { $.cookie(k,a[k],o); } window.location.reload(); })();"
    console.log ""
    console.log ""
    console.log ""
    console.log ""
    console.log ""
    console.log "|||||||||| Paste & run in another console to share session |||||||||"
    console.log session
    console.log "|||||||||||||||||||||||||||||"

  DebugTool
