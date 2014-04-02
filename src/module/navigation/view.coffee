#############################
#  View(UI logic) for navigation
#############################

define [ 'event', 'constant', 'i18n!nls/lang.js',
         'text!./module/navigation/template.html',
         'text!./module/navigation/template_data.html',
         'backbone', 'jquery', 'handlebars', 'UI.notification', 'MC.ide.template'
], ( ide_event, constant, lang, template, template_data ) ->

    #compile partial template
    MC.IDEcompile 'nav', template_data, { '.app-list-data' : 'nav-app-list-tmpl', '.stack-list-data' : 'nav-stack-list-tmpl', '.region-empty-list' : 'nav-region-empty-list-tmpl', '.region-list' : 'nav-region-list-tmpl' }

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

            Handlebars.registerHelper 'tolower', ( result ) ->
                return new Handlebars.SafeString result.toLowerCase()


            # off-canvas-navigation
            $("#off-canvas-menu").click ()->
                if $("#wrapper").hasClass("off-canvas")
                    return $("wrapper").removeClass("off-canvas")

                if $("#nav-app-region").children(".nav-empty").length
                    $("#off-canvas-stack").click()
                else
                    $("#off-canvas-app").click()

                $("#wrapper").addClass("off-canvas");
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
            $( this.el ).html Handlebars.compile template

            #push event
            ide_event.trigger ide_event.NAVIGATION_COMPLETE
            null

        appListRender : ->
            @$el.find( '#nav-app-region' ).html this.app_list_tmpl this.model.attributes
            null

        stackListRender : ->
            @$el.find( '#nav-stack-region' ).html this.stack_list_tmpl this.model.attributes
            null

        regionEmtpyListRender : ->
            @$el.find( '#nav-region-empty-list' ).html this.region_empty_list_tmpl this.model.attributes
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
