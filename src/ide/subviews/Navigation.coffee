
################################
#  View(UI logic) for navigation
################################

define [ "./NavigationTpl", 'backbone' ], ( NavPartsTpl ) ->

    Backbone.View.extend {

        events :
            "click #off-canvas-app"   : "showNavApp"
            "click #off-canvas-stack" : "showNavStack"

            'click .stack-list li, .app-list li' : 'openOps'

            'click #nav-show-empty' : 'showEmptyRegion'
            'click .icon-new-stack' : 'createStack'

        initialize : ()->
            @setElement $(NavPartsTpl.navigation()).appendTo("#wrapper").eq(0)

            # Bind events that doesn't belong to navigation dom
            $("#off-canvas-menu").click    _.bind( @showOffCanvas, @ )
            $("#off-canvas-overlay").click _.bind( @hideOffCanvas, @ )

            @updateStackList()
            @updateAppList()

            # Listen to AppList and StackList in order to update the list.
            @listenTo App.model.stackList(), "update", ()->
                # Delay the updating until the navigation is shown next time.
                if @showing
                    @updateStackList()
                else
                    @stackDirty = true
                return

            @listenTo App.model.appList(), "update change:state", ()->
                console.log "Navigation updated due to appList update", arguments
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

        openOps : ( event ) ->
            @hideOffCanvas()
            App.openOps $(event.currentTarget).attr("data-id")
            return

        createStack  : ( event ) ->
            region = $(event.currentTarget).closest("li").attr("data-region")
            if not region then return
            @hideOffCanvas()
            App.createOps( region )
            return

    }
