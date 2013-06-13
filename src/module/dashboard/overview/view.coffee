#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    OverviewView = Backbone.View.extend {

        el       : $( '#tab-content-dashboard' )

        template : Handlebars.compile $( '#overview-tmpl' ).html()

        events   :
            'click #map-region-spot-list li a ' : 'mapRegionClick'

        mapRegionClick : ( target ) ->
            console.log 'mapRegionClick'
            this.trigger 'RETURN_REGION_TAB', null

        render : () ->
            console.log 'dashboard overview render'
            $( this.el ).html this.template this.model.attributes
            #event.trigger event.NAVIGATION_COMPLETE
    }

    return OverviewView