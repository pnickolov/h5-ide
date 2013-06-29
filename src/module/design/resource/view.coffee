#############################
#  View(UI logic) for design/resource
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.fixedaccordion', 'UI.selectbox', 'UI.toggleicon', 'UI.searchbar', 'UI.filter'
], ( ide_event ) ->

    ResourceView = Backbone.View.extend {

        el         : $ '#resource-panel'

        initialize : ->
            #listen
            $( window   ).on 'resize', fixedaccordion.resize
            $( document ).on 'ready',  toggleicon.init
            $( document ).on 'ready',  searchbar.init
            $( document ).on 'ready',  selectbox.init
            #listen
            $( document ).delegate '#hide-resource-panel', 'click',         this.toggleResourcePanel
            $( document ).delegate '#resource-select',     'OPTION_CHANGE', this.resourceSelectEvent
            $( document ).delegate '#resource-panel',     'SEARCHBAR_SHOW', this.searchBarShowEvent
            $( document ).delegate '#resource-panel',     'SEARCHBAR_HIDE', this.searchBarHideEvent
            $( document ).delegate '#resource-panel',   'SEARCHBAR_CHANGE', this.searchBarChangeEvent
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.hideResourcePanel

        render   : ( template ) ->
            console.log 'resource render'
            $( this.el ).html template
            #
            fixedaccordion.resize()
            null

        listen   : ( model ) ->
            #set this.model
            this.model = model
            #listen model
            this.listenTo this.model, 'change:vailability_zone', this.vailabilityZoneRender

        resourceSelectEvent : ( event, id ) ->
            console.log 'resourceSelectEvent'
            fixedaccordion.show.call($($(this).parent().find('.fixedaccordion-head')[0]))

        searchBarShowEvent : ( event ) ->
            console.log 'searchBarShowEvent'
            $($(this).find('.search-panel')[0]).show()

        searchBarHideEvent : ( event ) ->
            console.log 'searchBarHideEvent'
            $($(this).find('.search-panel')[0]).hide()

        searchBarChangeEvent : ( event, value ) ->
            console.log 'searchBarChangeEvent'
            filter.update($($(this).find('.search-panel')[0]), value)

        toggleResourcePanel : ( event ) ->
            console.log 'toggleResourcePanel'
            #
            $( '#resource-panel' ).toggleClass 'hiden'
            $( event ).children().first().toggleClass( 'icon-double-angle-left' ).toggleClass 'icon-double-angle-right'
            $( '#canvas-panel' ).toggleClass 'left-hiden'

        hideResourcePanel : ( type ) ->
            console.log 'hideResourcePanel = ' + type

            if type is 'OPEN_APP'
                $( '#hide-resource-panel' ).trigger 'click'
                $( '#hide-resource-panel' ).hide()
            else
                #
                fixedaccordion.resize()

            if type is 'OPEN_STACK' or type is 'NEW_STACK'
                if $( '#resource-panel' ).attr( 'class' ).indexOf( 'hide' ) isnt -1 then $( '#hide-resource-panel' ).trigger 'click'
                $( '#hide-resource-panel' ).show()

        vailabilityZoneRender : ( result ) ->
            console.log 'vailabilityZoneRender'
            console.log result

    }

    return ResourceView
