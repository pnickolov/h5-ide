#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

    CGWModel = PropertyModel.extend {

        init : ( uid ) ->
            cgw = Design.instance().component( uid )

            @set {
                uid     : uid
                name    : cgw.get("name")
                BGP     : cgw.get("bgpAsn")
                ip      : cgw.get("ip")
            }
            null

        setIP   : ( ip ) ->
            Design.instance().component( @get("uid") ).set("ip", ip)
            null

        setBGP  : ( bgp ) ->
            Design.instance().component( @get("uid") ).set("bgpAsn", bgp)
            null
    }

    new CGWModel()
