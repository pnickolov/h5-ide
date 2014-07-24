define [ 'constant', 'MC', 'Design', 'TaHelper' ], ( constant, MC, Design, Helper ) ->
    i18n = Helper.i18n.short()


    unusedOgWontCreate = ( callback ) ->
        uid = null
        ogUnused = Design.modelClassForType(constant.RESTYPE.DBOG).some (og) ->
            uid = og.id
            !!og.connections().length

        if ogUnused
            callback Helper.message.warning uid, i18n.TA_MSG_WARNING_RDS_UNUSED_OG_NOT_CREATE
        else
            callback null

        null


    unusedOgWontCreate: unusedOgWontCreate