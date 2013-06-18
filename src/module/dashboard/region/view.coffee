#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    GegionView = Backbone.View.extend {

        el       : $( '#tab-content-region' )

        template : Handlebars.compile $( '#region-tmpl' ).html()

        events   :
            'click .return-overview'          : 'returnOverviewClick'

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        render   : () ->
            console.log 'dashboard region render'
            $( this.el ).html this.template this.model.attributes

        runAppClick : ( event ) ->
            console.log 'dashboard click to run app'
            ide_event.trigger ide_event.CLICK_RUN_APP, 'app', event.currentTarget.id

        addStackTab : ( ) ->
            console.log 'dashboard click to add stack'
            ide_event.trigger ide_event.ADD_STACK_TAB, region_name

    }

    return GegionView