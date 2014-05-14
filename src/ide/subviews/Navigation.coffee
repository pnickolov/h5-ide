
################################
#  View(UI logic) for navigation
################################

define [ "./NavigationTpl", "event", 'backbone' ], ( NavPartsTpl, ide_event ) ->

    Backbone.View.extend {

        events :
            "click #off-canvas-app"   : "showNavApp"
            "click #off-canvas-stack" : "showNavStack"

            'click .stack-list li' : 'openStack'
            'click .app-list li'   : 'openApp'

            'click #nav-show-empty' : 'showEmptyRegion'
            'click .icon-new-stack' : 'createNewStack'

        initialize : ()->
            @setElement $(NavPartsTpl.navigation()).appendTo("#wrapper").eq(0)

            # Bind events that doesn't belong to navigation dom
            $("#off-canvas-menu").click    _.bind( @showOffCanvas, @ )
            $("#off-canvas-overlay").click _.bind( @hideOffCanvas, @ )

            @updateStackList()
            @updateAppList()

            # Listen to AppList and StackList in order to update the list.
            @listenTo App.model.stackList(), "sort", ()->
                # Delay the updating until the navigation is shown next time.
                if @showing
                    @updateStackList()
                else
                    @stackDirty = true
                return

            @listenTo App.model.appList(), "sort", ()->
                if @showing
                    @updateAppList()
                else
                    @appDirty = true
                return

            return

        showOffCanvas : ()->
            if $("#wrapper").hasClass("off-canvas")
                return $("wrapper").removeClass("off-canvas")

            if @stackDirty then @updateStackList()
            if @appDirty   then @updateAppList()

            @showing = true
            @stackDirty = @appDirty = false

            if $("#nav-app-region").children(".nav-empty").length
                @showNavStack()
            else
                @showNavApp()

            $("#wrapper").addClass("off-canvas")
            return

        hideOffCanvas : ()->
            $("#wrapper").removeClass("off-canvas")
            @showing = false

        showNavApp : ()->
            $("#nav-app-region").show()
            $("#nav-stack").hide()
            $("#off-canvas-app").toggleClass("selected", true)
            $("#off-canvas-stack").toggleClass("selected", false)
            return

        showNavStack : ()->
            $("#nav-app-region").hide()
            $("#nav-stack").show()
            $("#off-canvas-app").toggleClass("selected", false)
            $("#off-canvas-stack").toggleClass("selected", true)
            return

        showEmptyRegion : () ->
            $("#nav-show-empty").hide()
            $("#nav-region-empty-list").show()
            return

        updateStackList : ()->
            list = App.model.stackList().groupByRegion( true )

            $('#nav-stack-region').html $.trim(NavPartsTpl.stacklist( list ))
            $('#nav-region-empty-list').html NavPartsTpl.regionlist( list )

        updateAppList : ()->
            $('#nav-app-region').html NavPartsTpl.applist( App.model.appList().groupByRegion() )

        # LEGACY code
        openStack : ( event ) -> @openDesignTab 'OPEN_STACK', $(event.currentTarget)
        openApp   : ( event ) -> @openDesignTab 'OPEN_APP', $(event.currentTarget)
        openDesignTab : ( type, $tgt ) ->
            @hideOffCanvas()
            if MC.data.design_submodule_count isnt -1
                return notification 'warning', lang.ide.NAV_DESMOD_NOT_FINISH_LOAD , false

            ide_event.trigger ide_event.OPEN_DESIGN_TAB, type, $tgt.text(), $tgt.parent().parent().attr('data-region'), $tgt.attr('data-id')

        createNewStack  : ( event ) ->
            region = $(event.currentTarget).closest("li").attr("data-region")
            if region
                @hideOffCanvas()
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, "NEW_STACK", null, region, null
            return

    }
