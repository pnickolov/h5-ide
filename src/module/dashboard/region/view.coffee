#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    GegionView = Backbone.View.extend {

        el       : $( '#tab-content-region' )

        template : Handlebars.compile $( '#region-tmpl' ).html()

        events   :
            'click .return-overview'          : 'returnOverviewClick'
            'click .stat-table-instance'      : 'showInstanceTable'

        showInstanceTable : ( target )->
            console.log target
            console.error 'click instance'

        returnOverviewClick : ( target ) ->
            console.log 'returnOverviewClick'
            this.trigger 'RETURN_OVERVIEW_TAB', null

        render   : () ->
            console.log 'dashboard region render'
            $( this.el ).html this.template this.model.attributes
    }

    return GegionView