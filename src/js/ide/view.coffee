#############################
#  View(UI logic) for Main
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    MainView = Backbone.View.extend {

        el       : $ '#main'

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

        showRegionTab : () ->
            console.log 'showRegionTab'
            #
            $( '#tab-content-region' ).addClass       'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-stack01' ).removeClass   'active'

        showStackTab : () ->
            console.log 'showStackTab'
            #
            $( '#tab-content-stack01' ).addClass      'active'
            $( '#tab-content-dashboard' ).removeClass 'active'
            $( '#tab-content-region' ).removeClass    'active'

        hideStackTab : () ->
            console.log 'hideStackTab'
            #
            $( '#tab-content-stack01' ).removeClass   'active'
    }

    view = new MainView()

    return view