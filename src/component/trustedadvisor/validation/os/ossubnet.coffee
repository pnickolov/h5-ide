define [
    'constant'
    'MC'
    'i18n!/nls/lang.js'
    'TaHelper'
    'CloudResources'
    ], ( constant, MC, lang, Helper, CloudResources ) ->

        i18n = Helper.i18n.short()

        __isSbConnectOut = ( sb ) ->
            rts = _.filter sb.connectionTargets( 'OsRouterAsso' ), ( obj ) ->
                obj.type is constant.RESTYPE.OSRT

            if not rts or not rts.length then return false

            extNets = []
            for rt in rts
                extNets = extNets.concat rt.get('extNetworkId')

            if not extNets or not extNets.length then return false

            true



        subnetHasPortShouldConncectedOut = ->
            badSbs = []
            subnets = Design.modelClassForType( constant.RESTYPE.OSSUBNET ).allObjects()

            for sb in subnets
                for child in sb.children()
                    port = null
                    if child.type in [ constant.RESTYPE.OSPORT, constant.RESTYPE.OSLISTENER ]
                        port = child
                    else if child.type is constant.RESTYPE.OSSERVER
                        port = child.embedPort()

                    if port and port.getFloatingIp() and not __isSbConnectOut( sb )
                        badSbs.push sb


            sbNames = _.map badSbs, ( sb ) ->
                "<span class='validation-tag tag-ossubnet'>#{sb.get( 'name' )}</span>"
            .join( ', ' )

            if not sbNames then return null

            Helper.message.error null, i18n.ERROR_SUBNET_HAS_PORT_SHOULD_CONNECTED_OUT, sbNames




        subnetHasPortShouldConncectedOut: subnetHasPortShouldConncectedOut
