#############################
#  View(UI logic) for design/property/subnet
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    SubnetView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-subnet-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:subnet render'

            data =
                component :
                    name : "vpc1"
                    uid  : "12345678-1234-1234-1234-123456789ABC"
                CIDRPrefix : "10.0."
                CIDR       : "0.0/24"
                networkACL : [
                    { data : {}
                    name : "DefaultACL"
                    rule : 3
                    isUsed : true
                    association : 10 },

                    { data : {}
                    name : "CustomACL1"
                    rule : 3
                    association : 10 }

                    { data : {}
                    name : "CustomACL1"
                    rule : 3
                    association : 10 }
                ]

            $( '.property-details' ).html this.template data

    }

    view = new SubnetView()

    return view
