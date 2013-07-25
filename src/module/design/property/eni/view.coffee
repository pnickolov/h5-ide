#############################
#  View(UI logic) for design/property/eni
#############################

define [ 'event',
         'backbone',
         'jquery',
         'handlebars',
         'UI.tooltip',
         'UI.tablist' ], ( ide_event ) ->

   ENIView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-eni-tmpl' ).html()

        events   :

            "change #property-eni-desc" : "setEniDesc"
            "change #property-eni-source-check" : "setEniSourceDestCheck"

        render     : () ->
            console.log 'property:eni render'
            $('.property-details').html this.template this.model.attributes

        setEniDesc : ( event ) ->

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger "SET_ENI_DESC", uid, event.target.value

        setEniSourceDestCheck : ( event ) ->

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger "SET_ENI_SOURCE_DEST_CHECK", uid, event.target.checked

    }

    view = new ENIView()

    return view
