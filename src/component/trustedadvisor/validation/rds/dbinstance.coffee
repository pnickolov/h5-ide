define [
    'constant'
    'MC'
    'Design'
    'TaHelper'
    'CloudResources'

], ( constant, MC, Design, Helper, CloudResources ) ->

    i18n = Helper.i18n.short()

    diff = ( oldcomp, newcomp ) ->
        not _.isEqual oldcomp, newcomp

    isOgValid = ->
        dbs = Design.modelClassForType(constant.RESTYPE.DBINSTANCE).filter (db) ->
            (db.get('instanceClass') is 'db.t1.micro') and not db.getOptionGroup().isDefault()

        return null if not dbs.length

        taId = ''
        nameStr = ''
        for db in dbs
            nameStr += "<span class='validation-tag'>#{db.get('name')}</span>, "
            taId += db.id

        nameStr = nameStr.slice 0, -2
        Helper.message.error taId, i18n.TA_MSG_ERROR_RDS_DB_T1_MICRO_DEFAULT_OPTION, nameStr


    isAzConsistent = ( uid ) ->
        db = Design.instance().component uid
        azName = db.get 'az'

        return null if not azName

        sbg = db.parent()
        if _.some(sbg.connectionTargets("SubnetgAsso"), ( sb )-> sb.parent().get( 'name' ) is azName)
            return null

        Helper.message.error uid, i18n.TA_MSG_ERROR_RDS_AZ_NOT_CONSISTENT, db.get('name'), azName

    isHaveEnoughIPForDB = (uid) ->

        _getSubnetRemainIPCount = (subnetModel) ->
            cidr = subnetModel.get('cidr')
            availableIPCount = subnetModel.getAvailableIPCountInSubnet()
            return availableIPCount

        subnetDBMap = {
            # subnetUID: [dbUID]
        }
        resultSubnetAry = []
        dbModels = Design.modelClassForType(constant.RESTYPE.DBINSTANCE).allObjects()
        _.each dbModels, (dbModel) ->
            subnetGroupModel = dbModel.get('__parent')
            connAry = subnetGroupModel.get('__connections')
            _.each connAry, (conModel) ->
                subnetModel = conModel.getTarget(constant.RESTYPE.SUBNET)
                subnetDBMap[subnetModel.id] = [] if not subnetDBMap[subnetModel.id]
                subnetDBMap[subnetModel.id] = _.union subnetDBMap[subnetModel.id], [dbModel.get('id')]
                null
            null
        _.each subnetDBMap, (dbAry, subnetUID) ->
            subnetModel = Design.instance().component(subnetUID)
            availableIPCount = _getSubnetRemainIPCount(subnetModel)
            if availableIPCount < dbAry.length
                resultSubnetAry.push(subnetModel.get('name'))
            null

        resultSubnetAry = _.map resultSubnetAry, (name) ->
            return "<span class='validation-tag tag-vpn'>#{name}</span>"

        if resultSubnetAry.length
            return {
                level: constant.TA.ERROR
                info: sprintf(i18n.TA_MSG_ERROR_HAVE_NOT_ENOUGH_IP_FOR_DB, resultSubnetAry.join(', '))
            }

        null

    isHaveReplicaStorageSmallThanOrigin = (uid) ->

        dbModel = Design.instance().component(uid)
        return null if not dbModel.master()

        storge = dbModel.get('allocatedStorage')
        srcStorge = dbModel.master().get('allocatedStorage')

        if storge < srcStorge
            return {
                uid: uid
                level: constant.TA.ERROR
                info: sprintf(i18n.TA_MSG_ERROR_REPLICA_STORAGE_SMALL_THAN_ORIGIN, dbModel.get('name'), dbModel.master().get('name'))
            }

        return null

    isSqlServerCross3Subnet = ( uid ) ->
        db = Design.instance().component uid
        og = db.getOptionGroup()

        return null if not db.isSqlserver()
        return null if og.isDefault()
        return null if _.every og.get( 'options' ), ( option ) ->
            option.OptionName isnt 'Mirroring'

        sbg = db.parent()
        azs = _.map sbg.connectionTargets('SubnetgAsso'), (sb) -> sb.parent()
        return null if _.uniq(azs).length > 2

        Helper.message.error uid, i18n.TA_MSG_ERROR_RDS_SQL_SERVER_MIRROR_MUST_HAVE3SUBNET, db.get('name')

    isBackupMaintenanceOverlap = ( uid ) ->
        db = Design.instance().component uid
        appId = db.get('appId')

        backupWindow = db.get 'backupWindow'
        maintenanceWindow = db.get 'maintenanceWindow'

        if appId
            appData = CloudResources(constant.RESTYPE.DBINSTANCE, Design.instance().region()).get appId
            backupWindow = backupWindow or appData.get 'PreferredBackupWindow'
            maintenanceWindow = maintenanceWindow or appData.get 'PreferredMaintenanceWindow'

        unless backupWindow and maintenanceWindow then return null

        backupTimeArray      = backupWindow.replace(/:/g, '').split('-')
        maintenanceTimeArray = maintenanceWindow.replace(/:/g, '').split('-')

        backupStart          = +backupTimeArray[0]
        backupEnd            = +backupTimeArray[1]
        maintenanceStart     = +maintenanceTimeArray[0].slice(3)
        maintenanceEnd       = +maintenanceTimeArray[1].slice(3)

        # Only maintenceTime cross a day
        if maintenanceEnd < maintenanceStart and backupStart < backupEnd
            if maintenanceEnd < backupStart and backupStart < maintenanceStart and backupEnd < maintenanceStart
                return null

        # Only backupTime cross a day
        else if backupEnd < backupStart and maintenanceStart < maintenanceEnd
            if backupEnd < maintenanceStart and maintenanceStart < backupStart and maintenanceEnd < backupStart
                return null

        # Both cross a day must be overlap
        else if backupEnd < backupStart and maintenanceEnd < maintenanceStart

        # Both maintenceTime and backupTime not cross a day
        else if backupStart > maintenanceEnd or backupEnd < maintenanceStart
            return null

        Helper.message.error uid, i18n.TA_MSG_ERROR_RDS_BACKUP_MAINTENANCE_OVERLAP, db.get('name')


    isMasterPasswordValid = ( uid ) ->
        db = Design.instance().component uid
        password = db.get('password')

        if password and  ( password is '****' or 8 <= password.length <= 41 ) then return null

        Helper.message.error uid, i18n.TA_MSG_ERROR_MASTER_PASSWORD_INVALID, db.get('name')

    isDBandOgBothModified = ( uid ) ->
        db = Design.instance().component uid
        og = db.getOptionGroup()

        if not db.get('appId') or not og.get('appId') or og.isDefault()
            return null

        originJson = Design.instance().__opsModel.getJsonData()

        dbOrigincomp = originJson.component[ uid ]
        ogOrigincomp = originJson.component[ og.id ]

        dbcomp = MC.canvas_data.component[ uid ]
        ogcomp = MC.canvas_data.component[ og.id ]

        unless diff(dbOrigincomp, dbcomp) and diff(ogOrigincomp, ogcomp)
            return null

        Helper.message.error uid, i18n.TA_MSG_ERROR_OG_DB_BOTH_MODIFIED, db.get('name'), og.get('name')



    isOgValid                   : isOgValid
    isAzConsistent              : isAzConsistent
    isHaveEnoughIPForDB         : isHaveEnoughIPForDB
    isSqlServerCross3Subnet     : isSqlServerCross3Subnet
    isBackupMaintenanceOverlap  : isBackupMaintenanceOverlap
    isMasterPasswordValid       : isMasterPasswordValid
    isHaveReplicaStorageSmallThanOrigin : isHaveReplicaStorageSmallThanOrigin
    isDBandOgBothModified       : isDBandOgBothModified

