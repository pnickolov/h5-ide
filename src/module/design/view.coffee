#############################
#  View(UI logic) for design
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    DesignView = Backbone.View.extend {

        el          : '#tab-content-design'

        initialize  : ->

        render   : ( template ) ->
            console.log 'design render'
            #render
            this.$el.html template
            #push DESIGN_COMPLETE
            this.trigger 'DESIGN_COMPLETE'

        listen   : ( model ) ->
            #set this.model
            this.model = model
            #listen model
            this.listenTo this.model, 'change:snapshot', this.writeOldDesignHtml

        html : ->
            data =
                resource : $( '#resource-panel' ).html(),
                property : $( '#property-panel' ).html(),
                canvas   : $( '#canvas-panel'   ).html()
            data

        writeOldDesignHtml : () ->
            console.log 'writeOldDesignHtml'
            #this.$el.empty().html this.model.get 'snapshot'
            $( '#resource-panel' ).html this.model.get( 'snapshot' ).resource
            $( '#canvas-panel'   ).html this.model.get( 'snapshot' ).canvas
            #$( '#property-panel' ).html this.model.get( 'snapshot' ).property
            #$( '#property-panel' ).empty()
            null

    }

    return DesignView
