define [
    'constant'
    'MC'
    'i18n!/nls/lang.js'
    'TaHelper'
    'CloudResources'
    ], ( constant, MC, lang, Helper, CloudResources ) ->

        i18n = Helper.i18n.short()

        isNatRouterConnectedExt = ( uid ) ->
            router = Design.instance().component uid

            unless router.get 'nat' then return null
            if router.connections( 'OsExtRouterAttach' ).length then return null

            Helper.message.error uid, i18n.ERROR_ROUTER_ENABLING_NAT_MUST_CONNECT_EXT


        isNatRouterConnectedExt: isNatRouterConnectedExt