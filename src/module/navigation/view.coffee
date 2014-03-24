#############################
#  View(UI logic) for navigation
#############################

define [ 'event', 'constant', 'i18n!nls/lang.js',
         './module/navigation/template',
         './module/navigation/template_data',
         'backbone', 'jquery', 'handlebars', 'UI.notification'
], ( ide_event, constant, lang, template, template_data ) ->

    NavigationView = Backbone.View.extend {

        #element
        el              : $ '#navigation'

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
            null

        render     : () ->
            #render html
            console.log 'navigation render'
            #$( this.el ).html this.template this.model.attributes
            #$( this.el ).html template
            $( this.el ).html template()

            #Collapsed Navigation Mouse Interaction
            this.hoverIntent()

            #push event
            ide_event.trigger ide_event.NAVIGATION_COMPLETE
            null

        appListRender : ->
            #render html
            console.log 'appListRender render'
            $( this.el ).find( '#nav-app-region' ).html template_data.app_list_data( @model.attributes )
            null

        stackListRender : ->
            #render html
            console.log 'stackListRender render'
            $( this.el ).find( '#nav-stack-region' ).html template_data.stack_list_data( @model.attributes )
            null

        regionEmtpyListRender : ->
            #render html
            console.log 'regionEmtpyListRender render'
            $( this.el ).find( '.nav-region-empty-list' ).html template_data.region_empty_list( @model.attributes )
            null

        regionListRender : ->
            #render html
            console.log 'regionListRender render'
            $( this.el ).find( '.nav-region-group' ).html template_data.region_list( @model.attributes )
            null

        stackListItemsClick : ( event ) ->
            console.log 'stack tab click event'
            target   = event.currentTarget
            tab_name = $( target ).text()
            @openDesignTab 'OPEN_STACK', tab_name, $( target ).attr( 'data-region-name' ), $( target ).attr( 'data-stack-id' )

        appListItemsClick : ( event ) ->
            console.log 'app tab click event'
            target   = event.currentTarget
            tab_name = $( target ).text()
            @openDesignTab 'OPEN_APP', $.trim( tab_name ), $( target ).attr( 'data-region-name' ) , $( target ).attr( 'data-app-id' )

        showEmptyRegionClick : ( event ) ->
            $( event.target ).parent().prev().find('.hide').show()
            $( event.target ).hide()

        createNewStackClick  : ( event ) ->
            console.log 'createNewStackClick'
            console.log $( event.target ).parent().parent().find('li a').first().attr( 'data-region-name' )
            if $( event.target ).parent().parent().find('li a').first().attr( 'data-region-name' ) is undefined then return
            @openDesignTab 'NEW_STACK', null, $( event.target ).parent().parent().find( 'li a' ).first().attr( 'data-region-name' ), null

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
            @openDesignTab 'NEW_STACK', null, current_region_name, null

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

        openDesignTab : ( type, tab_name, region_name, tab_id ) ->
            console.log 'openDesignTab', type, tab_name, region_name, tab_id
            if MC.data.design_submodule_count isnt -1
                notification 'warning', lang.ide.NAV_DESMOD_NOT_FINISH_LOAD , false
            else
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, type, tab_name, region_name, tab_id
    }

    return NavigationView
