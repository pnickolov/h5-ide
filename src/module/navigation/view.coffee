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
            'click .stack-list li'          : 'stackListItemsClick'
            'click .app-list li'            : 'appListItemsClick'
            'click .show-unused-region'     : 'showEmptyRegionClick'
            'click .create-new-stack'       : 'createNewStackClick'
            'click .create-new-empty-stack' : 'createNewEmptyStackClick'

            "click #off-canvas-app"   : "showOffCanvasApp"
            "click #off-canvas-stack" : "showOffCanvasStack"

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.hideNavigation
            null


            # off-canvas-navigation
            $("#off-canvas-menu").click ()->
                if $("#wrapper").hasClass("off-canvas")
                    return $("wrapper").removeClass("off-canvas")

                if $("#nav-app-region").children(".nav-empty").length
                    $("#off-canvas-stack").click()
                else
                    $("#off-canvas-app").click()

                $("#wrapper").addClass("off-canvas")
                return

            $("#off-canvas-overlay").click ()-> $("#wrapper").removeClass("off-canvas"); return

            return

        hideOffCanvas : ()-> $("#wrapper").removeClass("off-canvas"); return

        showOffCanvasApp : ()->
            $("#nav-app-region").show()
            $("#nav-stack").hide()
            $("#off-canvas-app").toggleClass("selected", true)
            $("#off-canvas-stack").toggleClass("selected", false)
            return

        showOffCanvasStack : ()->
            $("#nav-app-region").hide()
            $("#nav-stack").show()
            $("#off-canvas-app").toggleClass("selected", false)
            $("#off-canvas-stack").toggleClass("selected", true)
            return

        render     : () ->
            #render html
            console.log 'navigation render'
            #$( this.el ).html this.template this.model.attributes
            #$( this.el ).html template
            $( this.el ).html template()

            #push event
            ide_event.trigger ide_event.NAVIGATION_COMPLETE
            null

        appListRender : ->
            $( this.el ).find( '#nav-app-region' ).html template_data.app_list_data( @model.attributes )
            null

        stackListRender : ->
            $( this.el ).find( '#nav-stack-region' ).html template_data.stack_list_data( @model.attributes )
            null

        regionEmtpyListRender : ->
            $( this.el ).find( '#nav-region-empty-list' ).html template_data.region_empty_list( @model.attributes )
            null

        regionListRender : ->
            null

        stackListItemsClick : ( event ) ->
            console.log 'stack tab click event'
            target   = event.currentTarget
            tab_name = $( target ).text()

            @hideOffCanvas()

            @openDesignTab 'OPEN_STACK', tab_name, $( target ).attr( 'data-region-name' ), $( target ).attr( 'data-stack-id' )

        appListItemsClick : ( event ) ->
            console.log 'app tab click event'
            target   = event.currentTarget
            tab_name = $( target ).text()

            @hideOffCanvas()

            @openDesignTab 'OPEN_APP', $.trim( tab_name ), $( target ).attr( 'data-region-name' ) , $( target ).attr( 'data-app-id' )

        showEmptyRegionClick : () -> $("#nav-region-empty-list").addClass("show"); return

        createNewStackClick  : ( event ) ->
            region = $(event.currentTarget).closest("li").children("ul").children().eq(0).attr("data-region-name")
            if region
                @hideOffCanvas()
                @openDesignTab 'NEW_STACK', null, region, null
            return

        createNewEmptyStackClick  : ( event ) ->
            region_label = $( event.currentTarget ).parent().attr( 'data-empty-region-label' )

            current_region_name  = null
            _.map constant.REGION_SHORT_LABEL, ( value, key ) ->
                if value is region_label
                    current_region_name = key
                    return current_region_name

            @hideOffCanvas()
            @openDesignTab 'NEW_STACK', null, current_region_name, null

        regionNameClick      : ( event ) ->
            console.log 'regionNameClick'
            console.log $( event.target ).attr( 'data-region-name' )
            data_region_name = if $( event.target ).attr( 'data-region-name' ) is undefined then $( event.currentTarget ).attr( 'data-region-name' ) else $( event.target ).attr( 'data-region-name' )
            ide_event.trigger ide_event.NAVIGATION_TO_DASHBOARD_REGION, data_region_name

        dashboardGlobal : ->
            console.log 'dashboardGlobal'
            ide_event.trigger ide_event.NAVIGATION_TO_DASHBOARD_REGION, 'global'

        openDesignTab : ( type, tab_name, region_name, tab_id ) ->
            console.log 'openDesignTab', type, tab_name, region_name, tab_id
            if MC.data.design_submodule_count isnt -1
                notification 'warning', lang.ide.NAV_DESMOD_NOT_FINISH_LOAD , false
            else
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, type, tab_name, region_name, tab_id
    }

    return NavigationView
