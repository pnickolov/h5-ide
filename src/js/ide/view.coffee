#############################
#  View(UI logic) for Main
#############################

define [ 'backbone', 'jquery', 'handlebars', 'underscore' ], () ->

    MainView = Backbone.View.extend {

        el       : $ '#main'

        initialize : ->
            $( window ).on "resize", this.resizeEvent

        resizeEvent : ->
            console.log 'resizeEvent'
            $( '.main-content' ).height window.innerHeight - 95

        showDashbaordTab : () ->
            console.log 'showDashbaordTab'
            console.log 'MC.data.dashboard_type = ' + MC.data.dashboard_type
            if MC.data.dashboard_type is 'OVERVIEW_TAB' then this.showOverviewTab() else this.showRegionTab()

        showOverviewTab : () ->
            console.log 'showOverviewTab'
            #
            $( '#tab-content-dashboard' ).addClass  'active'
            $( '#tab-content-region' ).removeClass  'active'
            $( '#tab-content-stack01' ).removeClass 'active'
            #
            this.resizeEvent()

        showRegionTab : () ->
            console.log 'showRegionTab'
            #
            $( '#tab-content-region' ).addClass       'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-stack01' ).removeClass   'active'
            #
            this.resizeEvent()

        showTab : () ->
            console.log 'showTab'
            #
            $( '#tab-content-stack01' ).addClass      'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-region' ).removeClass    'active'
            #
            this.resizeEvent()
    }

    view = new MainView()

    return view