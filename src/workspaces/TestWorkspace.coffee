
define ["Workspace", "backbone"], ( Workspace, backbone )->

  TestView = Backbone.View.extend {

    initialize : ( attr )->
      @setElement $("<div class=''>#{attr.space.opsid}</div>").appendTo( attr.space.scene.spaceParentElement() )
  }

  class TestWorkspace extends Workspace

    isFixed  : ()-> @opsid is "dashboard"
    tabClass : ()-> if @isFixed() then "icon-dashboard" else "icon-stack-tabbar"
    title    : ()-> @opsid
    url      : ()-> "/"

    isWorkingOn : (id)-> @opsid is id


    initialize : ( opsid )->
      @opsid = opsid

      @view = new TestView({
        space : @
      })

  TestWorkspace
