#############################
#  View(UI logic) for design/property
#############################

define [ './temp_view',
         'backbone', 'jquery', 'handlebars'
         'UI.fixedaccordion', 'UI.modal', 'UI.selectbox', 'UI.tooltip', 'UI.notification', 'UI.scrollbar', 'UI.toggleicon'
], ( temp_view ) ->

    PropertyView = Backbone.View.extend {

        el                  : $ '#property-panel'
        #accordion_item_tmpl : Handlebars.compile $( '#accordion-item-tmpl' ).html()

        initialize : ->
            #listen
            $( document ).delegate '#hide-property-panel', 'click', this.togglePropertyPanel
            #listen
            $( window   ).on 'resize', fixedaccordion.resize

        render     : ( template ) ->
            console.log 'property render'
            $( this.el ).html template

        togglePropertyPanel : ( event ) ->
            console.log 'togglePropertyPanel'
            $( '#property-panel' ).toggleClass 'hiden'
            $( event ).children().first().toggleClass('icon-double-angle-left').toggleClass('icon-double-angle-right')
            $( '#canvas-panel' ).toggleClass 'right-hiden'

        refresh : ->
            console.log 'refresh'
            selectbox.init()
            temp_view.ready()

    }

    return PropertyView