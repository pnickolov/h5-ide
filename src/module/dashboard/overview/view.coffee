#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    OverviewView = Backbone.View.extend {

        el       : $( '#tab-content-dashboard' )

        template : Handlebars.compile $( '#overview-tmpl' ).html()

        events   :
            'click #map-region-spot-list > li' : 'mapRegionClick'
            'click #dashboard-create-stack-list > li' : 'createStackClick'

        mapRegionClick : ( event ) ->
            console.log 'mapRegionClick'
            this.trigger 'RETURN_REGION_TAB', event.currentTarget.id

        createStackClick : ( event ) ->
            console.log 'dashboard region create stack'
            ide_event.trigger ide_event.ADD_STACK_TAB, ($(event.currentTarget).data 'region')

        render : () ->
            console.log 'dashboard overview render'
            $( this.el ).html this.template this.model.attributes
            #event.trigger event.NAVIGATION_COMPLETE
    }

    return OverviewView