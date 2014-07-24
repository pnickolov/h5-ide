define [ 'constant', 'MC', 'Design', 'TaHelper' ], ( constant, MC, Design, Helper ) ->

    i18n = Helper.i18n.short()

    isOgValid = ( uid ) ->
        db = Design.instance().component uid
        if (db.get('instanceClass') is 'db.t1.micro') and not db.getOptionGroup().isDefault()
            return Helper.message.error uid, i18n.TA_MSG_ERROR_RDS_DB_T1_MICRO_DEFAULT_OPTION
        null


    isOgValid: isOgValid