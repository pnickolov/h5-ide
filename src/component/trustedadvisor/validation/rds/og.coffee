define [ 'constant', 'MC', 'Design', 'TaHelper' ], ( constant, MC, Design, Helper ) ->
    i18n = Helper.i18n.short()


    unusedOgWontCreate = ( callback ) ->
        ogUnused = Design.modelClassForType(constant.RESTYPE.DBOG).filter (og) ->
            not (og.isDefault() or og.connections().length)

        if not ogUnused.length
            callback null
            return null

        taId = ''
        nameStr = ''

        for og in ogUnused
            nameStr += "<span class='validation-tag'>#{og.get('name')}</span>, "
            taId += og.id

        nameStr = nameStr.slice 0, -2
        callback Helper.message.warning taId, i18n.TA_MSG_WARNING_RDS_UNUSED_OG_NOT_CREATE, nameStr

        null


    unusedOgWontCreate: unusedOgWontCreate