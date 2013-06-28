#############################
#  View(UI logic) for design
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    DesignView = Backbone.View.extend {

        el       : $( '#tab-content-stack01' )

        initialize : ->
            $( window ).on "resize", this.resizeEvent

        resizeEvent : ->
            console.log 'design:resizeEvent'
            main_middle    = $ '#canvas-panel'
            resource_panel = $ '#resource-panel'
            property_panel = $ '#property-panel'
            resource_panel_marginLeft  = resource_panel.css 'margin-left'
            property_panel_marginRight = property_panel.css 'margin-right'
            panel_width = resource_panel.width()
            main      = $ '#main'
            nav       = $ '#navigation'
            nav_left  = nav.css 'left'
            nav_width = nav.width()
            win_width = $( window ).width()

            main_middle.width  win_width - nav_width - nav_left - panel_width * 2 - resource_panel_marginLeft - property_panel_marginRight
            main_middle.height main.height() - $( '#tab-bar' ).height()
            nav.height window.innerHeight - 50

        render   : ( template ) ->
            console.log 'design render'
            $( this.el ).html template
            #push DESIGN_COMPLETE
            this.trigger 'DESIGN_COMPLETE'
    }

    return DesignView