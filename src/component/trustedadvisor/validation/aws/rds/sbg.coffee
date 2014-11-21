define [ 'constant', 'MC', 'Design', 'TaHelper', 'CloudResources' ], ( constant, MC, Design, Helper, CloudResources ) ->
    i18n = Helper.i18n.short()

    isSbgHasSbin2Az = ( uid ) ->
        # Because of lang file has refactored in other branch, so put new tips here for temporary
        tmpTip = "Subnet Group %s must have subnets in at least 2 Availability Zones."

        sbg = Design.instance().component uid
        sbs = sbg.connectionTargets("SubnetgAsso")
        azs = []

        azs = _.map sbs, ( sb ) -> sb.parent()
        uniqAzCount = _.uniq( azs ).length
        
        if Design.instance().region() in ['cn-north-1']
            minAZCount = 1
        else
            minAZCount = 2

        if uniqAzCount >= minAZCount then return null

        Helper.message.error uid, sprintf( tmpTip, sbg.get( 'name' ) )


    isSbgHasSbin2Az: isSbgHasSbin2Az