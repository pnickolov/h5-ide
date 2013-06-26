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
        recent_info : Handlebars.compile $( '#recent-info-tmpl' ).html()

        events   :
            'click #map-region-spot-list > li' : 'mapRegionClick'
            'click #dashboard-create-stack-list > li' : 'createStackClick'

        renderMapResult : ->
            console.log 'dashboard overview-result render'
            $( this.el ).find( '.overview-result-list' ).html this.overview_result this.model.attributes
            cur_tmpl = $( this.el ).find( '.overview-result' ).html()
            $( this.el ).find('#map-region-spot-list').html cur_tmpl

            null

        renderMapEmpty : ->
            console.log 'dashboard overview-empty render'
            $( this.el ).find( '.overview-empty-list' ).html this.overview_empty this.model.attributes
            cur_tmpl = $( this.el ).find( '.overview-result' ).html() + $( this.el ).find( '.overview-empty' ).html()
            $( this.el ).find('#map-region-spot-list').html cur_tmpl

            null

        renderStatInfo : ->
            console.log 'dashboard stat-info render'
            $( this.el ).find( '.stat-info-list' ).html this.stat_info this.model.attributes

            null

        renderPlatformAttrs : ->
            console.log 'dashboard platform-attr render'
            $( this.el ).find( '.platform-attr-list' ).html this.platform_attr this.model.attributes

            cur_tmpl = $( this.el ).find( '.platform-attr' ).html()
            $( this.el ).find('#dashboard-create-stack-list').html cur_tmpl

            null

        renderRecentInfo : ->
            console.log 'dashboard recent info render'
            $( this.el ).find( '.recent-info-list' ).html this.recent_info this.model.attributes
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
    }

    return OverviewView