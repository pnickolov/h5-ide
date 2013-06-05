#############################
#  View(UI logic) for navigation
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    NavigationView = Backbone.View.extend {

        el       : $( '#navigation' )

        template : Handlebars.compile $( '#navigation-tmpl' ).html()

        events   :
            'click #nav-dashboard-region a'  : 'dashboardRegionClick'
            'click .nav-region-list-items a' : 'regionListItemsClick'

        initialize : ->
            #

        render     : ->
        	#render html
            console.log 'navigation render'
            $( this.el ).html this.template this.model

            #Collapsed Navigation Mouse Interaction
            this.hoverIntent()

            #push event
            event.trigger event.NAVIGATION_COMPLETE

        dashboardRegionClick : ( event ) ->
            if event.target.parentNode.className isnt 'show-unused-region'
                alert 'add dashboard region'

        regionListItemsClick : ( event ) ->
            alert 'add tab click event'

        hoverIntent          : ->
            $('.nav-head').hoverIntent {

                timeout  : 100

                over     : () ->
                    if $('#navigation').hasClass 'collapsed'
                        $( this ).delay( 300 ).addClass 'collapsed-show'

                out      : () ->
                    $( this ).removeClass 'collapsed-show'
            }
    }

    return NavigationView