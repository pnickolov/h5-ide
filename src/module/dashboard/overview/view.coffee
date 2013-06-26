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

        events   :
            'click #map-region-spot-list > li' : 'mapRegionClick'
            'click #dashboard-create-stack-list > li' : 'createStackClick'

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