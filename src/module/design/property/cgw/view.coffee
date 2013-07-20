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

        render     : ( data ) ->
            console.log 'property:cgw render'

            this.uid = data.uid
            $( '.property-details' ).html this.template data

        onChangeRouting : () ->
            $( '#property-cgw-bgp-wrapper' ).toggle $('#property-routing-dynamic').is(':checked')

            change.value = ""
            change.event = "CHANGE_BGP"
            this.trigger "CHANGE_BGP", this.uid, change

        onChangeBGP : ( event ) ->
            change.value = event.target.value
            change.event = "CHANGE_BGP"

            this.trigger "CHANGE_BGP", this.uid, change

        onChangeName : ( event ) ->
            change.value = event.target.value
            change.event = "CHANGE_NAME"

            this.trigger "CHANGE_NAME", this.uid, change

        onChangeIP   : ( event ) ->
            change.value = event.target.value
            change.event = "CHANGE_IP"

            this.trigger "CHANGE_IP", this.uid, change

        setName : ( name ) ->
            $( "#property-cgw-name" ).val name

        setBGP : ( bgp ) ->
            dynamic = false
            if bgp
                $( '#property-cgw-bgp' ).val bgp
                dynamic = true

            $( '#property-routing-dynamic' ).prop "checked", dynamic
            $( '#property-routing-static' ).prop  "checked", !dynamic
            $( '#property-cgw-bgp-wrapper').toggle dynamic

        setIP : ( ip ) ->
            $( '#property-cgw-ip' ).val ip

        showError : ( type, errorInfo ) ->
            null
    }

    view = new CGWView()

    eventTgtMap =
        "CHANGE_BGP"  : "#property-cgw-bgp"
        "CHANGE_NAME" : "#property-cgw-name"
        "CHANGE_IP"   : "#property-cgw-ip"

    change =
        value   : ""
        event   : ""
        context : view
        accept  : () ->
            $( eventTgtMap[ this.event ] ).attr "lastValue", this.value

            if this.event == "CHANGE_NAME"
                $( '#property-title' ).html this.value

        reject  : ( reason ) ->
            # TODO : show error on the input

            # Restore last value
            $ipt = $( eventTgtMap[ this.event ] )
            $ipt.val( $ipt.attr "lastValue" )

    return view
