define [
    'constant'
    'MC'
    'i18n!/nls/lang.js'
    'TaHelper'
    'CloudResources'
    ], ( constant, MC, lang, Helper, CloudResources ) ->

        i18n = Helper.i18n.short()

        isPoolConnectedwithListener = ( uid ) ->
            pool = Design.instance().component uid

            if pool.connections( 'OsListenerAsso' ).length then return null

            Helper.message.error uid, i18n.ERROR_POOL_XXX_MUST_BE_CONNECTED_TO_A_LISTENER, pool.get 'name'


        isMemberBelongsConnectedSubnet = ( uid ) ->
            pool = Design.instance().component uid

            members = pool.connectionTargets('OsPoolMembership')
            notConnectedMembers = _.reject members, ( m ) ->
                if m.parent() is pool.parent() then return true

                memberRt = m.parent().connectionTargets('OsRouterAsso')[0]
                poolRt = pool.parent().connectionTargets('OsRouterAsso')[0]
                if memberRt and memberRt is poolRt then return true

                false

            memberNames = _.map notConnectedMembers, ( nc ) ->
                "<span class='validation-tag tag-ospoolmember'>#{nc.get( 'name' )}</span>"
            .join( ', ' )

            if not memberNames then return null
            Helper.message.error uid, i18n.ERROR_POOL_AND_MEMBER_SUBNET_NOT_CONNECTED, pool.get( 'name' ), memberNames


        isPoolConnectedwithListener: isPoolConnectedwithListener
        isMemberBelongsConnectedSubnet: isMemberBelongsConnectedSubnet

