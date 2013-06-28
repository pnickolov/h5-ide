#############################
#  View(UI logic) for design/resource
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.fixedaccordion' ], ( ide_event ) ->

    ResourceView = Backbone.View.extend {

        el       : $ '#resource-panel'

        initialize : ->
            #listen resize
            $( window ).on "resize", fixedaccordion.resize
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.hideResourcePanel
            #listen
            $( document ).delegate '#hide-resource-panel', 'click', this.toggleResourcePanel

        render   : ( template ) ->
            console.log 'resource render'
            $( this.el ).html template
            null

        toggleResourcePanel : ( event ) ->
            console.log 'toggleResourcePanel'
            #
            $( '#resource-panel' ).toggleClass 'hiden'
            $( event ).children().first().toggleClass( 'icon-double-angle-left' ).toggleClass 'icon-double-angle-right'
            $( '#canvas-panel' ).toggleClass 'left-hiden'
            #
            canvasPanelResize()

        hideResourcePanel : ( type ) ->
            console.log 'hideResourcePanel = ' + type

            if type is 'OPEN_APP'
                $( '#hide-resource-panel' ).trigger 'click'
                $( '#hide-resource-panel' ).hide()

            if type is 'OPEN_STACK' or type is 'NEW_STACK'
                if $( '#resource-panel' ).attr( 'class' ).indexOf( 'hide' ) isnt -1 then $( '#hide-resource-panel' ).trigger 'click'
                $( '#hide-resource-panel' ).show()

    }

    return ResourceView
