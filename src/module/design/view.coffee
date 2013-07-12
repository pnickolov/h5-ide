#############################
#  View(UI logic) for design
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    DesignView = Backbone.View.extend {

        el          : $ '#tab-content-design'

        initialize  : ->
            $( window   ).on "resize", this.resizeEvent
            $( '#tab-content-design' ).bind 'DOMNodeInserted', this.domNodeInserted

        resizeEvent : ->
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
            #render
            $( this.el ).html template
            #push DESIGN_COMPLETE
            this.trigger 'DESIGN_COMPLETE'

        listen   : ( model ) ->
            #set this.model
            this.model = model
            #listen model
            this.listenTo this.model, 'change:snapshot', this.writeOldDesignHtml

        writeOldDesignHtml : () ->
            console.log 'writeOldDesignHtml'
            this.$el.html this.model.get 'snapshot'

        domNodeInserted : ->
            console.log 'wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww'
    }

    return DesignView