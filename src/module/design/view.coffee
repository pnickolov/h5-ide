#############################
#  View(UI logic) for design
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    DesignView = Backbone.View.extend {

        el       : $( '#tab-content-stack01' )

        render   : ( template ) ->
            console.log 'design render'
            $( this.el ).html template
            #push DESIGN_COMPLETE
            this.trigger 'DESIGN_COMPLETE'
    }

    return DesignView