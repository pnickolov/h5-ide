define [ 'constant', 'MC', 'Design', 'TaHelper' ], ( constant, MC, Design, Helper ) ->

    i18n = Helper.i18n.short()

    isOgValid = ( uid ) ->
        db = Design.instance().component uid
        if (db.get('instanceClass') is 'db.t1.micro') and not db.getOptionGroup().isDefault()
            return Helper.message.error uid, i18n.TA_MSG_ERROR_RDS_DB_T1_MICRO_DEFAULT_OPTION
        null

    isAzConsistent = ( uid ) ->
        db = Design.instance().component uid
        azName = db.get 'az'

        if not azName then return null

        sbg = db.parent()
        if _.some(sbg.connectionTargets("SbAsso"), ( sb )-> sb.parent().get( 'name' ) is azName)
            return null

        Helper.message.error uid, i18n.TA_MSG_ERROR_RDS_AZ_NOT_CONSISTENT, db.get('name'), azName

    isAccessibleHasNoIgw = ( uid ) ->
        db = Design.instance().component uid
        if not db.get 'accessible' then return null

        vpc = Design.modelClassForType(constant.RESTYPE.VPC).theVPC()
        if _.some(vpc.children(), (child) -> child.type is constant.RESTYPE.IGW)
            return null

        Helper.message.error uid, i18n.TA_MSG_ERROR_RDS_ACCESSIBLE_NOT_HAVE_IGW



    isOgValid           : isOgValid
    isAzConsistent      : isAzConsistent
    isAccessibleHasNoIgw:isAccessibleHasNoIgw