#############################
#  View(UI logic) for design/property
#############################

define [ './temp_view',
         'event'
         'backbone', 'jquery', 'handlebars'
         'UI.fixedaccordion', 'UI.modal', 'UI.selectbox', 'UI.tooltip', 'UI.notification', 'UI.scrollbar', 'UI.toggleicon'
], ( temp_view, ide_event ) ->

    PropertyView = Backbone.View.extend {

        el                  : $ '#property-panel'

        initialize : ->
            #listen
            $( document ).delegate '#hide-property-panel', 'click', this.togglePropertyPanel
            $( window   ).on 'resize', fixedaccordion.resize

        render     : ( template ) ->
            console.log 'property render'
            $( this.el ).html template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-property render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#property-panel' ).html template

        togglePropertyPanel : ( event ) ->
            console.log 'togglePropertyPanel'
            $( '#property-panel' ).toggleClass 'hiden'
            $( event ).children().first().toggleClass('icon-double-angle-left').toggleClass('icon-double-angle-right')
            $( '#canvas-panel' ).toggleClass 'right-hiden'

        refresh : ->
            console.log 'refresh'
            #selectbox.init()
            temp_view.ready()

    }

    return PropertyView