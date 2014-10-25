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

            rt = rts[0]
            if !rt or !rt.get('extNetworkId') then return false

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


            sbNames = _.map _.uniq(badSbs), ( sb ) ->
                "<span class='validation-tag tag-ossubnet'>#{sb.get( 'name' )}</span>"
            .join( ', ' )

            if not sbNames then return null

            Helper.message.error null, i18n.ERROR_SUBNET_HAS_PORT_SHOULD_CONNECTED_OUT, sbNames

        isSubnetCIDRConflict = () ->

            subnetModels = Design.modelClassForType(constant.RESTYPE.OSSUBNET).allObjects()
            isCidrConflict = Design.modelClassForType(constant.RESTYPE.SUBNET).isCidrConflict

            conflictSubnet1 = null
            conflictSubnet2 = null

            for subnetModel1 in subnetModels

                for subnetModel2 in subnetModels

                    if subnetModel1 is subnetModel2
                        continue

                    haveConflict = isCidrConflict(subnetModel1.get('cidr'), subnetModel2.get('cidr'))
                    if haveConflict
                        conflictSubnet1 = subnetModel1
                        conflictSubnet2 = subnetModel2
                        break

                if conflictSubnet1
                    break

            if conflictSubnet1

                name1 = conflictSubnet1.get('name')
                name2 = conflictSubnet2.get('name')
                cidr1 = conflictSubnet1.get('cidr')
                cidr2 = conflictSubnet2.get('cidr')

                return Helper.message.error null, i18n.ERROR_SUBNET_HAS_CONFLICT_CIDR_WITH_OTHERS, name1, cidr1, name2, cidr2

        subnetHasPortShouldConncectedOut: subnetHasPortShouldConncectedOut
        isSubnetCIDRConflict: isSubnetCIDRConflict
