define [
    'constant'
    'MC'
    'i18n!/nls/lang.js'
    'TaHelper'
    'CloudResources'
    ], ( constant, MC, lang, Helper, CloudResources ) ->

        i18n = Helper.i18n.short()

        rtMustConnecteToOneSubnet = ( uid ) ->
            rt = Design.instance().component uid

            if rt.connections( 'OsRouterAsso' ).length then return null

            Helper.message.error uid, i18n.ERROR_ROUTER_XXX_MUST_CONNECT_TO_AT_LEAST_ONE_SUBNET, rt.get 'name'



        rtMustConnecteToOneSubnet: rtMustConnecteToOneSubnet