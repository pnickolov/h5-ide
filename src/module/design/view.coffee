#############################
#  View(UI logic) for design
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    DesignView = Backbone.View.extend {

        el       : $( '#tab-content-stack01' )

        template : Handlebars.compile $( '#design-tmpl' ).html()

        render   : () ->
            console.log 'design render'
            $( this.el ).html this.template()
            event.trigger event.DESIGN_COMPLETE
    }

    return DesignView