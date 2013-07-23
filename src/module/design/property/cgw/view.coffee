#############################
#  View(UI logic) for design/property/cgw
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   CGWView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-cgw-tmpl' ).html()

        events   :
            "click #property-cgw .cgw-routing input" : 'onChangeRouting'
            "change #property-cgw-bgp"  : 'onChangeBGP'
            "change #property-cgw-name" : 'onChangeName'
            "change #property-cgw-ip"   : 'onChangeIP'

        render     : () ->
            console.log 'property:cgw render'
            $( '.property-details' ).html this.template this.model.attributes

        onChangeRouting : () ->
            $( '#property-cgw-bgp-wrapper' ).toggle $('#property-routing-dynamic').is(':checked')

            change.value = ""
            change.event = "CHANGE_BGP"
            this.trigger "CHANGE_BGP", change

        onChangeBGP : ( event ) ->

            change.handled = false
            change.value   = event.target.value
            change.event   = "CHANGE_BGP"

            this.trigger "CHANGE_BGP", change

        onChangeName : ( event ) ->

            # TODO : Validate Name
            $( '#property-title' ).html event.target.value

            change.value = event.target.value
            change.event = "CHANGE_NAME"

            this.trigger "CHANGE_NAME", change

        onChangeIP   : ( event ) ->

            # TODO : Validate IP
            change.value = event.target.value
            change.event = "CHANGE_IP"

            this.trigger "CHANGE_IP", change

        setBGP : ( bgp ) ->
            dynamic = false
            if bgp
                $( '#property-cgw-bgp' ).val bgp
                dynamic = true

            $( '#property-routing-dynamic' ).prop "checked", dynamic
            $( '#property-routing-static' ).prop  "checked", !dynamic
            $( '#property-cgw-bgp-wrapper').toggle dynamic
    }

    view = new CGWView()

    eventTgtMap =
        "CHANGE_BGP"  : "#property-cgw-bgp"
        "CHANGE_NAME" : "#property-cgw-name"
        "CHANGE_IP"   : "#property-cgw-ip"

    change =
        value   : ""
        event   : ""
        handled : true
        done    : ( error ) ->
            if this.handled
                return

            if error
                # TODO : show error on the input

                # Restore last value
                $ipt = $( eventTgtMap[ this.event ] )
                $ipt.val( $ipt.attr "lastValue" )
            else
                $( eventTgtMap[ this.event ] ).attr "lastValue", this.value

            this.handled = true
            null

    return view
