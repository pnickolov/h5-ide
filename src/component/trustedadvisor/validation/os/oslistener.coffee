define [
    'constant'
    'MC'
    'i18n!/nls/lang.js'
    'TaHelper'
    'CloudResources'
    ], ( constant, MC, lang, Helper, CloudResources ) ->

        i18n = Helper.i18n.short()

        isListenerConnectedwithPool = ( uid ) ->
            listener = Design.instance().component uid

            if listener.connections( 'OsListenerAsso' ).length then return null

            Helper.message.error uid, i18n.ERROR_LISTENER_XXX_MUST_BE_CONNECTED_TO_A_POOL, listener.get 'name'


        isListenerConnectedwithPool: isListenerConnectedwithPool