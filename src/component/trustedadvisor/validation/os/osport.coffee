define [
    'constant'
    'MC'
    'i18n!/nls/lang.js'
    'TaHelper'
    'CloudResources'
    ], ( constant, MC, lang, Helper, CloudResources ) ->

        i18n = Helper.i18n.short()

        isPortConnectwithServer = ( uid ) ->
            port = Design.instance().component uid

            connectedServer = _.some port.connectionTargets( 'OsPortUsage' ), ( target ) ->
                target.type is constant.RESTYPE.OSSERVER

            if connectedServer then return null

            Helper.message.error uid, i18n.ERROR_PORT_MUST_CONNECT_WITH_SERVER, port.get 'name'


        isPortConnectwithServer: isPortConnectwithServer