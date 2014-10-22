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


        isPoolConnectedwithListener: isPoolConnectedwithListener