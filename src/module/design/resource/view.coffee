#############################
#  View(UI logic) for design/resource
#############################

define [ 'backbone', 'jquery', 'handlebars', 'UI.fixedaccordion' ], () ->

    ResourceView = Backbone.View.extend {

        el       : $( '#resource-panel' )

        #template : Handlebars.compile $( '#resource-tmpl' ).html()

        events   :
            'click #hide-resource-panel' : 'hideResourcePanel'

        initialize : ->
            $( window ).on "resize", fixedaccordion.resize

        render   : ( template ) ->
            console.log 'resource render'
            $( this.el ).html template
            null

        hideResourcePanel : ( event ) ->
            console.log 'hideResourcePanel'
            #
            resource_panel = $ '#resource-panel'
            resource_panel.toggleClass 'hiden'
            #
            $( event ).children().first().toggleClass( 'icon-double-angle-left' ).toggleClass 'icon-double-angle-right'
            #
            main_middle    = $ '#canvas-panel'
            main_middle.toggleClass 'left-hiden'
            #
            canvasPanelResize()

    }

    return ResourceView
