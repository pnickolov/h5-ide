
define [], ()->

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
