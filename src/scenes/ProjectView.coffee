

define [ "./ProjectTpl", "backbone"], ( ProjectTpl )->

  Backbone.View.extend {

    initialize : ( attr )->

      @scene = attr.scene

      @setElement $( ProjectTpl.frame() ).appendTo( "#scenes" )
      @render()

    render : ()->
      @$el.find(".project-list").text( @scene.project.get("name") )
      @$el.find(".user-menu").text( App.user.get("username") )
      return

  }
