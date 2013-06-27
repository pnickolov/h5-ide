#############################
#  View(UI logic) for design/resource
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    ResourceView = Backbone.View.extend {

        el       : $( '#resource-panel' )

        events   :
            'click #hide-resource-panel' : 'hideResourcePanel'

        #template : Handlebars.compile $( '#resource-tmpl' ).html()

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
