#############################
#  View(UI logic) for navigation
#############################

define [ 'event', 'constant', 'i18n!nls/lang.js'
         'backbone', 'jquery', 'handlebars', 'UI.notification'
], ( ide_event, constant, lang ) ->

    NavigationView = Backbone.View.extend {

        #element
        el              : $ '#navigation'

        #templdate
        #template        : Handlebars.compile $( '#navigation-tmpl' ).html()
        app_list_tmpl    : Handlebars.compile $( '#nav-app-list-tmpl' ).html()
        stack_list_tmpl  : Handlebars.compile $( '#nav-stack-list-tmpl' ).html()
        region_empty_list_tmpl : Handlebars.compile $( '#nav-region-empty-list-tmpl' ).html()
        region_list_tmpl : Handlebars.compile $( '#nav-region-list-tmpl' ).html()

        #events
        events   :
            'click .stack-list a'           : 'stackListItemsClick'
            'click .app-list a'             : 'appListItemsClick'
            'click .show-unused-region a'   : 'showEmptyRegionClick'
            'click .create-new-stack'       : 'createNewStackClick'
            'click .create-new-empty-stack' : 'createNewEmptyStackClick'
            'click .region-name'            : 'regionNameClick'
            'click #dashboard-global'       : 'dashboardGlobal'

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.hideNavigation

            Handlebars.registerHelper 'tolower', ( result ) ->
                return new Handlebars.SafeString result.toLowerCase()

        render     : ( template ) ->
            #render html
            console.log 'navigation render'
            #$( this.el ).html this.template this.model.attributes
            #$( this.el ).html template
            $( this.el ).html Handlebars.compile template

            #Collapsed Navigation Mouse Interaction
            this.hoverIntent()

            #push event
            ide_event.trigger ide_event.NAVIGATION_COMPLETE
            null

        appListRender : ->
            #render html
            console.log 'appListRender render'
            $( this.el ).find( '#nav-app-region' ).html this.app_list_tmpl this.model.attributes
            null

        stackListRender : ->
            #render html
            console.log 'stackListRender render'
            $( this.el ).find( '#nav-stack-region' ).html this.stack_list_tmpl this.model.attributes
            null

        regionEmtpyListRender : ->
            #render html
            console.log 'regionEmtpyListRender render'
            $( this.el ).find( '.nav-region-empty-list' ).html this.region_empty_list_tmpl this.model.attributes
            null

        regionListRender : ->
            #render html
            console.log 'regionListRender render'
            $( this.el ).find( '.nav-region-group' ).html this.region_list_tmpl this.model.attributes
            null

        stackListItemsClick : ( event ) ->
            console.log 'stack tab click event'
            target   = event.currentTarget
            #nav      = $ '#navigation'
            #main     = $ '#main'
            tab_name = $( target ).text()
            #
            #ide_event.trigger ide_event.OPEN_STACK_TAB, tab_name, $( target ).attr( 'data-region-name' ), $( target ).attr( 'data-stack-id' )
            this.checkDesignLoadComplete ide_event.OPEN_STACK_TAB, tab_name, $( target ).attr( 'data-region-name' ), $( target ).attr( 'data-stack-id' )

        appListItemsClick : ( event ) ->
            console.log 'app tab click event'
            target   = event.currentTarget
            #nav      = $ '#navigation'
            #main     = $ '#main'
            tab_name = $( target ).text()
            #
            #ide_event.trigger ide_event.OPEN_APP_TAB, $.trim( tab_name ), $( target ).attr( 'data-region-name' ) , $( target ).attr( 'data-app-id' )
            this.checkDesignLoadComplete ide_event.OPEN_APP_TAB, $.trim( tab_name ), $( target ).attr( 'data-region-name' ) , $( target ).attr( 'data-app-id' )

        showEmptyRegionClick : ( event ) ->
            $( event.target ).parent().prev().find('.hide').show()
            $( event.target ).hide()

        createNewStackClick  : ( event ) ->
            console.log 'createNewStackClick'
            console.log $( event.target ).parent().parent().find('li a').first().attr( 'data-region-name' )
            if $( event.target ).parent().parent().find('li a').first().attr( 'data-region-name' ) is undefined then return
            #
            #ide_event.trigger ide_event.ADD_STACK_TAB, $( event.target ).parent().parent().next().find( 'li a' ).first().attr( 'data-region-name' )
            this.checkDesignLoadComplete ide_event.ADD_STACK_TAB, $( event.target ).parent().parent().find( 'li a' ).first().attr( 'data-region-name' )

        createNewEmptyStackClick  : ( event ) ->
            console.log 'createNewEmptyStackClick'
            console.log $( event.currentTarget ).attr( 'data-empty-region-label' )
            region_label         = $( event.currentTarget ).attr( 'data-empty-region-label' )
            current_region_name  = null
            _.map constant.REGION_SHORT_LABEL, ( value, key ) ->
                if value is region_label
                    current_region_name = key
                    return current_region_name
            console.log 'current_region_name = ' + current_region_name
            #
            #ide_event.trigger ide_event.ADD_STACK_TAB, $( event.target ).parent().parent().next().find( 'li a' ).first().attr( 'data-region-name' )
            this.checkDesignLoadComplete ide_event.ADD_STACK_TAB, current_region_name

        regionNameClick      : ( event ) ->
            console.log 'regionNameClick'
            console.log $( event.target ).attr( 'data-region-name' )
            data_region_name = if $( event.target ).attr( 'data-region-name' ) is undefined then $( event.currentTarget ).attr( 'data-region-name' ) else $( event.target ).attr( 'data-region-name' )
            ide_event.trigger ide_event.NAVIGATION_TO_DASHBOARD_REGION, data_region_name

        dashboardGlobal : ->
            console.log 'dashboardGlobal'
            ide_event.trigger ide_event.NAVIGATION_TO_DASHBOARD_REGION, 'global'

        hoverIntent          : ->
            $('.nav-head').hoverIntent {

                timeout  : 100

                over     : () ->
                    $( this ).delay( 300 ).addClass 'collapsed-show'

                out      : () ->
                    $( this ).removeClass 'collapsed-show'
            }

        checkDesignLoadComplete : ( type, tab_name, region_name, tab_id ) ->
            console.log 'checkDesignLoadComplete'
            if MC.data.design_submodule_count isnt -1
                notification 'warning', lang.ide.NAV_DESMOD_NOT_FINISH_LOAD , false
            else
                ide_event.trigger type, tab_name, region_name, tab_id
    }

    return NavigationView