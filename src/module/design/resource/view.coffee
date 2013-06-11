#############################
#  View(UI logic) for design/resource
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    ResourceView = Backbone.View.extend {

        el       : $( '#resource-panel' )

        template : Handlebars.compile $( '#resource-tmpl' ).html()

        render   : () ->
            console.log 'resource render'
            $( this.el ).html this.template()
            #event.trigger event.DESIGN_COMPLETE
    }

    return ResourceView