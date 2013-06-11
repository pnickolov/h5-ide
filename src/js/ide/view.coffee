#############################
#  View(UI logic) for Main
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    MainView = Backbone.View.extend {

        el       : $( '#main' )

        showDashbaordTab : ( target ) ->
            console.log 'showDashbaordTab'
            $( '#tab-content-dashboard' ).addClass 'active'
            $( '#tab-content-region' ).removeClass 'active'

        showRegionTab : ( target ) ->
            console.log 'showRegionTab'
            #temp
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-region' ).addClass       'active'
    }

    view = new MainView()

    return view