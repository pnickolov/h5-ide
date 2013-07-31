#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    OverviewView = Backbone.View.extend {

        el       : $( '#tab-content-dashboard' )

        #template : Handlebars.compile $( '#overview-tmpl' ).html()

        overview_result: Handlebars.compile $( '#overview-result-tmpl' ).html()
        overview_empty: Handlebars.compile $( '#overview-empty-tmpl' ).html()
        stat_info: Handlebars.compile $( '#stat-info-tmpl' ).html()
        platform_attr: Handlebars.compile $( '#platform-attr-tmpl' ).html()
        recent_edited_stack : Handlebars.compile $( '#recent-edited-stack-tmpl' ).html()
        recent_launched_app : Handlebars.compile $( '#recent-launched-app-tmpl' ).html()
        recent_stopped_app : Handlebars.compile $( '#recent-stopped-app-tmpl' ).html()

        events   :
            'click #map-region-spot-list > li'          : 'mapRegionClick'
            'click #dashboard-create-stack-list > li'   : 'createStackClick'
            'click .dashboard-recent-list > li'         : 'openItem'

        renderMapResult : ->
            console.log 'dashboard overview-result render'

            cur_tmpl = (this.overview_result this.model.attributes) + (this.overview_empty this.model.attributes)

            $( this.el ).find('#map-region-spot-list').html cur_tmpl

            null

        renderMapEmpty : ->
            console.log 'dashboard overview-empty render'

            cur_tmpl = (this.overview_result this.model.attributes) + (this.overview_empty this.model.attributes)

            $( this.el ).find('#map-region-spot-list').html cur_tmpl

            null

        renderStatInfo : ->
            console.log 'dashboard stat-info render'
            $( this.el ).find( '.stat-info-list' ).html this.stat_info this.model.attributes

            null

        renderPlatformAttrs : ->
            console.log 'dashboard platform-attr render'

            $( this.el ).find('#dashboard-create-stack-list').html this.platform_attr this.model.attributes
            $('#dashboard-create-stack').find('a').first().removeClass('disabled').addClass('btn-primary')

            null

        renderRecentEditedStack : ->
            console.log 'dashboard recent edited stack render'
            $( this.el ).find( '#recent-edited-stack' ).html this.recent_edited_stack this.model.attributes
            null

        renderRecentLaunchedApp : ->
            console.log 'dashboard recent launched app render'
            $( this.el ).find( '#recent-launched-app' ).html this.recent_launched_app this.model.attributes
            null

        renderRecentStoppedApp : ->
            console.log 'dashboard recent stopped app render'
            $( this.el ).find( '#recent-stopped-app' ).html this.recent_stopped_app this.model.attributes
            null

        mapRegionClick : ( event ) ->
            console.log 'mapRegionClick'
            this.trigger 'RETURN_REGION_TAB', event.currentTarget.id

        createStackClick : ( event ) ->
            console.log 'dashboard region create stack'
            ide_event.trigger ide_event.ADD_STACK_TAB, ($(event.currentTarget).data 'region')

        render : ( template ) ->

            console.log 'dashboard overview render'

            $( this.el ).html template

        openItem : (event) ->
            console.log 'click item'

            me = this

            id = event.target.id

            if id.indexOf('app-') == 0
                ide_event.trigger ide_event.OPEN_APP_TAB, event.target.text, event.target.region, event.target.id
            else if id.indexOf('stack-') == 0
                ide_event.trigger ide_event.OPEN_STACK_TAB, event.target.text, event.target.region, event.target.id

            null
            
    }

    return OverviewView