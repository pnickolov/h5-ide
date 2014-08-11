#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ 'ApiRequest'
         'ResDiff'
         '../base/view'
         'og_dropdown'
         './template/stack_instance'
         './template/stack_replica'
         './template/stack_component'
         'i18n!/nls/lang.js'
         'constant'
         'CloudResources'
         'rds_pg'
         'jqtimepicker'
], ( ApiRequest, ResDiff, PropertyView, OgDropdown, template_instance, template_replica, template_component, lang, constant, CloudResources, parameterGroup  ) ->

    noop = ()-> null

    DBInstanceView = PropertyView.extend {

        events:
            'change #property-dbinstance-name': 'changeInstanceName'
            'change #property-dbinstance-mutil-az-check': 'changeMutilAZ'
            'change #property-dbinstance-storage': 'changeAllocatedStorage'
            'keyup #property-dbinstance-storage': 'inputAllocatedStorage'
            'change #property-dbinstance-iops-check': 'changeProvisionedIOPSCheck'
            'change #property-dbinstance-iops-value': 'changeProvisionedIOPS'
            'change #property-dbinstance-master-username': 'changeUserName'
            'change #property-dbinstance-master-password': 'changePassWord'
            'change #property-dbinstance-database-name': 'changeDatabaseName'
            'change #property-dbinstance-database-port': 'changeDatabasePort'
            'change #property-dbinstance-public-access-check': 'changePublicAccessCheck'
            'change #property-dbinstance-version-update': 'changeVersionUpdate'
            'change #property-dbinstance-auto-backup-check': 'changeAutoBackupCheck'
            'change #property-dbinstance-backup-period': 'changeBackupPeriod'

            'click #property-dbinstance-backup-window-select input': 'changeBackupOption'
            'change #property-dbinstance-backup-window-start-time': 'changeBackupTime'
            'OPTION_CHANGE #property-dbinstance-backup-window-duration': 'changeBackupTime'

            'click #property-dbinstance-maintenance-window-select input': 'changeMaintenanceOption'
            'OPTION_CHANGE #property-dbinstance-maintenance-window-start-day-select': 'changeMaintenanceTime'
            'OPTION_CHANGE #property-dbinstance-maintenance-window-duration': 'changeMaintenanceTime'
            'change #property-dbinstance-maintenance-window-start-time': 'changeMaintenanceTime'

            'OPTION_CHANGE #property-dbinstance-license-select': 'changeLicense'
            'OPTION_CHANGE #property-dbinstance-engine-version-select': 'changeVersion'
            'OPTION_CHANGE #property-dbinstance-class-select': 'changeClass'
            'OPTION_CHANGE #property-dbinstance-preferred-az': 'changeAZ'

            'OPTION_CHANGE #property-dbinstance-charset-select': 'changeCharset'

            'change #property-dbinstance-apply-immediately': 'changeApplyImmediately'

            'OPTION_CHANGE': 'checkChange'
            'change *': 'checkChange'

        checkChange: () ->
            return unless @resModel.get 'appId'
            that = @
            _.defer () ->
                comp = that.resModel.serialize()

                differ = new ResDiff({
                    old : component: that.originComp
                    new : comp
                })

                if differ.getChangeInfo().hasResChange
                    that.$( '.apply-immediately-section' ).show()
                else
                    that.$( '.apply-immediately-section' ).hide()

        durationOpertions: [ 0.5, 1, 2, 2.5, 3 ]

        genDuration: ( selectedValue ) ->
            _.map @durationOpertions, ( value ) ->
                value: value, selected: value is selectedValue


        changeCharset: ( event, value ,data ) ->
            @resModel.set 'characterSetName', value

        changeApplyImmediately: (event) ->

            value = event.target.checked
            @resModel.set('applyImmediately', value)

        changeLicense: ( event, value, data ) ->
            @resModel.set 'license', value
            @renderLVIA()

        changeVersion: ( event, value, data ) ->
            origEngineVersion = @resModel.get 'engineVersion'
            @resModel.set 'engineVersion', value
            @resModel.setDefaultParameterGroup( origEngineVersion )
            @resModel.setDefaultOptionGroup( origEngineVersion )
            @renderOptionGroup()
            @renderParameterGroup()
            @renderLVIA()

        changeClass: ( event, value, data ) ->
            @resModel.set 'instanceClass', value
            @setDefaultAllocatedStorage()
            true

        setDefaultAllocatedStorage: () ->

            range = @resModel.getAllocatedRange()
            currentValue = @resModel.get('allocatedStorage')

            if range.min > currentValue or range.max < currentValue

                defaultStorage = @resModel.getDefaultAllocatedStorage()
                @resModel.set('allocatedStorage', defaultStorage)
                $('#property-dbinstance-storage').val(defaultStorage)
                @updateIOPSCheckStatus()

        _getTimeData: (timeStr) ->

            defaultValue = {
                startHour: '00',
                startMin: '00',
                startTime: "00:00",
                duration: 0.5,
                startWeek: 'Mondey'
            }

            return defaultValue if not timeStr

            try

                _appendZero = (str) -> if str.length is 1 then return "0#{str}" else return str

                timeAry = timeStr.split('-')
                startTimeStr = timeAry[0]
                endTimeStr = timeAry[1]

                startTimeAry = startTimeStr.split(':')
                endTimeAry = endTimeStr.split(':')

                # for mon:hour:min
                if startTimeAry.length is 3

                    startWeekStr = startTimeAry[0]
                    endWeekStr = endTimeAry[0]

                    startTimeAry = startTimeAry.slice(1)
                    endTimeAry = endTimeAry.slice(1)

                startHour = Number(startTimeAry[0])
                startMin = Number(startTimeAry[1])

                endHour = Number(endTimeAry[0])
                endMin = Number(endTimeAry[1])

                # get duration
                start = new Date()
                end = new Date(start)
                start.setHours(startHour)
                start.setMinutes(startMin)
                end.setHours(endHour)
                end.setMinutes(endMin)

                # duration is hour
                duration = (end - start)/1000/60/60
                if duration < 0
                    duration = 24 + duration

                startHourStr = _appendZero(String(startHour))
                startMinStr = _appendZero(String(startMin))

                return {
                    startHour: startHourStr,
                    startMin: startMinStr,
                    startTime: "#{startHourStr}:#{startMinStr}",
                    duration: duration,
                    startWeek: startWeekStr
                }

            catch err

                return defaultValue

        _getTimeStr: (startTimeStr, duration, startWeek) ->

            addZero = (num) ->

                numStr = String(num)
                if numStr.length is 1
                    numStr = '0' + numStr
                return numStr

            try

                startTime = startTimeStr.split(':')
                startHour = Number(startTime[0])
                startMin = Number(startTime[1])

                start = new Date()
                start.setHours(startHour)
                start.setMinutes(startMin)
                end = new Date(start.getTime() + 1000 * 60 * 60 * duration)
                endHour = end.getHours()
                endMin = end.getMinutes()

                # add zero on number
                startHour = addZero(startHour)
                startMin = addZero(startMin)
                endHour = addZero(endHour)
                endMin = addZero(endMin)

                startTimeStr = "#{startHour}:#{startMin}"
                endTimeStr = "#{endHour}:#{endMin}"

                if startWeek

                    startTimeStr = "#{startWeek}:#{startTimeStr}"
                    endTimeStr = "#{startWeek}:#{endTimeStr}"

                return "#{startTimeStr}-#{endTimeStr}"

            catch err

                return ''

        _setBackupTime: () ->

            # hour = Number($('#property-dbinstance-backup-window-start-hour').val())
            # min = Number($('#property-dbinstance-backup-window-start-minute').val())
            startTime = $('#property-dbinstance-backup-window-start-time').val()
            duration = Number($('#property-dbinstance-backup-window-duration .selection').text())
            timeStr = @_getTimeStr(startTime, duration)
            @resModel.set('backupWindow', timeStr)

        _setMaintenanceTime: () ->

            # hour = Number($('#property-dbinstance-maintenance-window-start-hour').val())
            # min = Number($('#property-dbinstance-maintenance-window-start-minute').val())
            startTime = $('#property-dbinstance-maintenance-window-start-time').val()
            duration = Number($('#property-dbinstance-maintenance-window-duration .selection').text())
            week = $('#property-dbinstance-maintenance-window-start-day-select').find('.item.selected').data('id')
            timeStr = @_getTimeStr(startTime, duration, week)
            @resModel.set('maintenanceWindow', timeStr)

        getModelJSON: () ->

            attr = @resModel.toJSON()

            # for app edit
            if @isAppEdit
                attr.isAppEdit = @isAppEdit
                _.extend attr, @appModel.toJSON()
                _.extend attr, @getOriginAttr()

            attr

        getOriginAttr: () ->


            if @originComp and @appModel

                allocatedStorage = @originComp.resource.AllocatedStorage
                iops = @originComp.resource.Iops

                return {
                    originAllocatedStorage: allocatedStorage,
                    originIOPS: iops
                    originBackupWindow: @appModel.get 'PreferredBackupWindow'
                    originMaintenanceWindow: @appModel.get 'PreferredMaintenanceWindow'
                }

            else

                return null

        render: () ->

            attr = @getModelJSON()

            backupTime = @_getTimeData(attr.backupWindow)
            maintenanceTime = @_getTimeData(attr.maintenanceWindow)

            attr.backup = backupTime
            attr.maintenance = maintenanceTime
            attr.backupDurations = @genDuration backupTime.duration
            attr.maintenanceDurations = @genDuration maintenanceTime.duration

            attr.hasSlave = !!@resModel.slaves().length
            attr.engineType = @resModel.engineType()

            _.extend attr, {
                isOracle: @resModel.isOracle()
                isSqlserver: @resModel.isSqlserver()
                isPostgresql: @resModel.isPostgresql()
            }

            if @resModel.master()
                attr.sourceDbName = @resModel.master().get('name')

            spec = @resModel.getSpecifications()
            lvi = @resModel.getLVIA spec

            attr.licenses = lvi[0]
            attr.versions = lvi[1]
            attr.classes  = lvi[2]

            template = template_instance

            # if replica
            if @resModel.master()
                if @isAppEdit
                    attr.hideAZConfig = true
                else
                    template = template_replica
                attr.masterIops = @resModel.master().get 'iops'

            # if snapshot
            else if attr.snapshotId
                template = template_instance
                snapshotModel = @resModel.getSnapshotModel()
                attr.snapshotSize = Number(snapshotModel.get('AllocatedStorage'))

            # if oracle
            if @resModel.isOracle()
                attr.isOracle = true
                attr.oracleCharset = _.map Design.modelClassForType(constant.RESTYPE.DBINSTANCE).oracleCharset, (oc) ->
                    charset: oc, selected: oc is attr.characterSetName

            # iops info
            if @resModel.isSqlserver()
                attr.iopsInfo = 'Requires a fixed ratio of 10 IOPS / GB storage'
            else
                attr.iopsInfo = 'Supports IOPS / GB ratios between 3 and 10'

            # render
            @$el.html template attr

            @setTitle(attr.name)

            @renderLVIA()
            @renderOptionGroup()

            # set Start Day week selection
            weekStr = maintenanceTime?.startWeek
            if weekStr
                $select = $('#property-dbinstance-maintenance-window-start-day-select')
                $item = $select.find(".item[data-id='#{weekStr}']").addClass('selected')
                $select.find('.selection').text($item.text())

            # set iops check status
            @updateIOPSCheckStatus()

            @pgDropdown = new parameterGroup(@resModel).renderDropdown()
            $("#property-dbinstance-parameter-group-select").html(@pgDropdown.el)
            @bindParsley()
            $('#property-dbinstance-maintenance-window-start-time, #property-dbinstance-backup-window-start-time').timepicker({
                'timeFormat': 'H:i'
                'step': 1
            })
            @getInstanceStatus() if @isAppEdit

            # listen change event
            @resModel.on 'change:iops', (val) ->

                if @isAppEdit
                    originValue = that.getOriginAttr()
                    $tipDom = @$el.find('.property-info-iops-adjust-tip')
                    if originValue is val
                        $tipDom.removeClass('hide')
                    else
                        $tipDom.addClass('hide')

            attr.name

        bindParsley: ->

            that = this

            db = @resModel
            validateStartTime = (val) ->
                if not /^(([0-1]?[0-9])|(2?[0-3])):[0-5]?[0-9]$/.test val
                        'Provide a valid time value from 00:00 to 23:59.'

            @$('#property-dbinstance-backup-window-start-time').parsley 'custom', validateStartTime
            @$('#property-dbinstance-maintenance-window-start-time').parsley 'custom', validateStartTime

            @$('#property-dbinstance-database-name').parsley 'custom', ( val ) ->
                switch db.engineType()
                    when 'mysql'
                        if val.length > 64 then return 'Max length is 64.'
                    when 'postgresql'
                        if val.length > 63 then return 'Max length is 63.'
                        if not /[a-z_]/.test val[0] then return 'Must begin with a letter or an underscore'
                    when 'oracle'
                        if val.length > 8 then return 'Max length is 8.'

                null


            @$('#property-dbinstance-storage').parsley 'custom', (val) ->

                storage = Number(val)

                originValue = that.getOriginAttr()

                allocatedRange = that.resModel.getAllocatedRange()

                min = allocatedRange.min
                max = allocatedRange.max

                if that.isAppEdit

                    if originValue and (storage < originValue.originAllocatedStorage)
                        return 'Allocated storage cannot be reduced.'

                if not (storage >= min and storage <= max)
                    return "Must be an integer from #{min} to #{max}"

                source = that.resModel.source()
                if source and storage < +source.get('AllocatedStorage')
                    return 'Snapshot storage need large than original value'

            @$('#property-dbinstance-iops-value').parsley 'custom', (val) ->

                storage = $('#property-dbinstance-storage').val()

                iopsRange = that._getIOPSRange(storage)

                defaultIOPS = that._getDefaultIOPS(storage)

                iops = Number(val)

                if iops < 1000
                    return "Require at least 1000 IOPS"

                # if not that.resModel.isSqlserver() and storage < Math.round(iops / 10)
                #     return "Require #{Math.round(iops / 10)}-#{Math.round(iops / 3)} GB Allocated Storage for #{iops} IOPS"

                if (iops % 1000) isnt 0
                    return "Require a multiple of 1000"

                if iops >= iopsRange.minIOPS and iops <= iopsRange.maxIOPS
                    return null

                return "Require IOPS / GB ratios between 3 and 10"

            @$('#property-dbinstance-master-password').parsley 'custom', (val) ->

                if val.indexOf('/') isnt -1 or val.indexOf('"') isnt -1 or val.indexOf('@') isnt -1
                    return 'Cannot contain character /,",@'

                if that.resModel.isMysql()
                    min = 8
                    max = 41
                if that.resModel.isOracle()
                    min = 8
                    max = 30
                if that.resModel.isSqlserver()
                    min = 8
                    max = 128
                if that.resModel.isPostgresql()
                    min = 8
                    max = 128
                if val.length >= min and val.length <= max
                    return null

                return "Must contain from #{min} to #{max} characters"

        renderOptionGroup: ->

            # if can create custom og

            regionName       = Design.instance().region()
            attr             = @getModelJSON()
            attr.canCustomOG = false
            engineCol     = CloudResources(constant.RESTYPE.DBENGINE, regionName)
            engineOptions = engineCol.getOptionGroupsByEngine(regionName, attr.engine)
            ogOptions     = engineOptions[@resModel.getMajorVersion()] if engineOptions
            defaultInfo = engineCol.getDefaultByNameVersion(regionName, attr.engine, attr.engineVersion)

            if defaultInfo and defaultInfo.canCustomOG
                attr.canCustomOG = defaultInfo.canCustomOG
            else
                attr.canCustomOG = true if engineOptions and ogOptions

            @$el.find('.property-dbinstance-optiongroup').html template_component.optionGroupDropDown(attr)

            # init option group dropdown
            if attr.canCustomOG

                $ogDropdown = @$el.find('.property-dbinstance-optiongroup-placeholder')
                ogDropdown = new OgDropdown({
                    el: $ogDropdown
                    dbInstance: @resModel
                })
                $ogDropdown.html ogDropdown.render({
                        engine: attr.engine
                        engineVersion: attr.engineVersion
                        majorVersion: @resModel.getMajorVersion()
                    }).el

            else

                @$el.find('.property-dbinstance-optiongroup').hide()

        renderParameterGroup: ->
            #update selection
            @pgDropdown.setSelection(@resModel.get 'pgName')
            null

        # Render License, Version, InstanceClass and multi-AZ
        renderLVIA: ->

            spec = @resModel.getSpecifications()
            lvi  = @resModel.getLVIA spec

            data = {
                licenses : lvi[0]
                versions : lvi[1]
                classes  : lvi[2]
                azCapable: lvi[3]
            }
            attr = @getModelJSON()
            attr.classInfo = @resModel.getInstanceClassDict()
            _.extend data, attr

            $('#lvia-container').html template_component.lvi(data)

            spec = @resModel.getSpecifications()
            lvi = @resModel.getLVIA spec
            multiAZCapable = lvi[3]

            # hack for SQL Server
            engine = @resModel.get('engine')
            multiAZCapable = true if (engine in ['sqlserver-ee', 'sqlserver-se'])

            if not multiAZCapable
                @resModel.set('multiAz', false)

            # set az list

            sgData = {
                multiAZCapable: multiAZCapable
            }
            sgData = _.extend sgData, attr
            subnetGroupModel = @resModel.parent()
            sgData.subnetGroupName = subnetGroupModel.get('name')
            connAry = subnetGroupModel.get('__connections')
            azUsedMap = {}
            _.each connAry, (subnetModel) ->
                azName = subnetModel.getTarget(constant.RESTYPE.SUBNET).parent().get('name')
                azUsedMap[azName] = true
                null
            usedAZCount = _.size(azUsedMap)
            if usedAZCount < 2
                sgData.azNotEnough = true

            $('#property-dbinstance-mutil-az').html template_component.propertyDbinstanceMutilAZ(sgData)

            @renderAZList()

            @

        renderAZList: () ->

            spec = @resModel.getSpecifications()
            lvi  = @resModel.getLVIA spec
            optionalAzAry = lvi[4]
            attr = @getModelJSON()

            # set preferred AZ list
            region = Design.instance().get('region')
            dragAZs = Design.modelClassForType(constant.RESTYPE.AZ).allObjects()
            dragAZs = _.map dragAZs, (azModel) ->
                return azModel.get('name')
            avaliableAZ = []
            _.each optionalAzAry, (az) ->
                avaliableAZ.push(az)
                null
            avaliableAZ = _.intersection(avaliableAZ, dragAZs)

            # render
            azData = _.map avaliableAZ, (az) ->
                return {
                    name: az
                }
            $('#property-dbinstance-preferred-az').html template_component.preferred_az(azData)
            if attr.az and (attr.az in avaliableAZ)
                selectedAZ = attr.az
            else
                selectedAZ = 'no'
            $preferredAZSelect = $('#property-dbinstance-preferred-az')
            $item = $preferredAZSelect.find(".item[data-id='#{selectedAZ}']").addClass('selected')
            $preferredAZSelect.find('.selection').text($item.text())

        changeInstanceName: (event) ->

            that = this

            target = $ event.currentTarget

            if PropertyView.checkResName(@resModel.get('id'), target, 'DBInstance')

                value = target.val()

                target.parsley 'custom', ( val ) ->

                    if (val[val.length - 1]) is '-' or (val.indexOf('--') isnt -1)
                        return errTip

                    if that.resModel.isSqlserver()
                        min = 1
                        max = 10
                    else
                        min = 1
                        max = 58
                    errTip = "Must contain from #{min} to #{max} alphanumeric characters or hyphens and first character must be a letter, cannot end with a hyphen or contain two consecutive hyphens"
                    if val.length < min or val.length > max
                        return errTip

                    if not MC.validate('letters', val[0])
                        return errTip

                if target.parsley 'validate'

                    @resModel.setName value
                    @setTitle value
                    # @resModel.set 'instanceId', value

            null

        changeMutilAZ: (event) ->

            value = event.target.checked
            $select = $('.property-dbinstance-preferred-az')
            if value
                $select.find('.item').remove('selected')
                $item = $select.find(".item[data-id='no']").addClass('selected')
                $select.find('.selection').text($item.text())
                $select.hide()
                @resModel.set 'az', ''
                @renderAZList()
            else
                $select.show()

            @resModel.set 'multiAz', value

        changeAZ: ( event, name, data ) ->

            if name is 'no'
                @resModel.set 'az', ''
            else
                @resModel.set 'az', name

            # @renderLVIA()

        updateIOPSCheckStatus: (newStorage) ->

            that = this

            if newStorage
                storge = newStorage
            else
                storge = that.resModel.get 'allocatedStorage'

            if not (that.resModel.master() and not that.isAppEdit)

                iops = that.resModel.get 'iops'
                if that._haveEnoughStorageForIOPS(storge)
                    that._disableIOPSCheck(false)
                else
                    that._disableIOPSCheck(true)

        _disableIOPSCheck: (isDisable) ->

            checkedDom = $('#property-dbinstance-iops-check')[0]

            if isDisable

                $('#property-dbinstance-iops-check').attr('disabled', 'disabled')
                $('.property-dbinstance-iops-value-section').hide()
                $('#property-dbinstance-iops-value').val('')
                @resModel.setIops 0
                checkedDom.checked = false

            else

                $('#property-dbinstance-iops-check').removeAttr('disabled')
                checked = checkedDom.checked
                if checked
                    $('.property-dbinstance-iops-value-section').show()
                    checkedDom.checked = true
                else
                    $('.property-dbinstance-iops-value-section').hide()
                    checkedDom.checked = false
                # @resModel.setIops ''

        _haveEnoughStorageForIOPS: (storge) ->

            iopsRange = @_getIOPSRange(storge)
            if iopsRange.minIOPS >= 1000 or iopsRange.maxIOPS >= 1000
                return true
            else
                return false

        _getIOPSRange: (storage) ->

            if @resModel.isSqlserver()
                minIOPS = storage * 10
                maxIOPS = storage * 10
            else
                minIOPS = storage * 3
                maxIOPS = storage * 10

            return {
                minIOPS: minIOPS
                maxIOPS: maxIOPS
            }

        _getDefaultIOPS: (storage) ->

            base = 1000
            count = 0
            iopsRange = @_getIOPSRange(storage)

            while ++count

                value = base * count
                if value >= iopsRange.minIOPS and value <= iopsRange.maxIOPS
                    return value
                if value > iopsRange.maxIOPS
                    return null

        changeAllocatedStorage: (event) ->

            that = this
            target = $(event.target)
            value = Number(target.val())

            if target.parsley('validate') and that.changeProvisionedIOPS()
                that.resModel.set 'allocatedStorage', value
                that.updateIOPSCheckStatus()

        inputAllocatedStorage: (event) ->

            that = this
            target = $(event.target)
            value = Number(target.val())

            # if target.parsley('validate') and that.changeProvisionedIOPS()
            that.updateIOPSCheckStatus(value)

        changeProvisionedIOPSCheck: (event) ->

            value = event.target.checked

            storage = Number($('#property-dbinstance-storage').val())
            iopsRange = @_getIOPSRange(storage)

            # for replica
            if @resModel.master() and not @isAppEdit
                if value
                    @resModel.setIops @resModel.master().get('iops')
                else
                    @resModel.setIops 0
            else
                if value
                    $('.property-dbinstance-iops-value-section').show()
                    if iopsRange.minIOPS >= 1000 or iopsRange.maxIOPS >= 1000
                        defaultIOPS = @_getDefaultIOPS(storage)
                        if defaultIOPS
                            $('#property-dbinstance-iops-value').val(defaultIOPS)
                            @resModel.setIops defaultIOPS
                else
                    $('.property-dbinstance-iops-value-section').hide()
                    $('#property-dbinstance-iops-value').val('')
                    @resModel.setIops 0

        changeProvisionedIOPS: (event) ->

            that = this

            if $('#property-dbinstance-iops-check')[0].checked

                target = $('#property-dbinstance-iops-value')
                value = target.val()
                iops = Number(value)

                storage = Number($('#property-dbinstance-storage').val())

                if target.parsley 'validate'

                    originValue = that.getOriginAttr()
                    if originValue and originValue.originIOPS and (iops isnt originValue.originIOPS)
                        $('.property-info-iops-adjust-tip').show()
                    else
                        $('.property-info-iops-adjust-tip').hide()

                    that.resModel.setIops Number(iops)
                    that.resModel.set 'allocatedStorage', storage
                    return true

                return false

            else

                return true

        changeUserName: (event) ->

            that = this
            target = $(event.target)
            value = target.val()

            target.parsley 'custom', (val) ->

                if MC.validate('alphanum', val) and MC.validate('letters', val[0])
                    if that.resModel.isMysql()
                        min = 1
                        max = 16
                    if that.resModel.isOracle()
                        min = 1
                        max = 30
                    if that.resModel.isSqlserver()
                        min = 1
                        max = 128
                    if that.resModel.isPostgresql()
                        min = 2
                        max = 16
                    if val.length >= min and val.length <= max
                        return null
                return "Must be #{min} to #{max} alphanumeric characters and first character must be a letter"

            if target.parsley 'validate'
                @resModel.set 'username', value

        changePassWord: (event) ->

            that = this
            target = $(event.target)
            value = target.val()

            if target.parsley 'validate'
                @resModel.set 'password', value
                # $('#property-dbinstance-master-password').attr('data-tooltip', "Current password: #{value}").removeClass('tooltip').addClass('tooltip')

        changeDatabaseName: (event) ->
            $target = $ event.currentTarget
            if not $target.parsley 'validate' then return

            @resModel.set 'dbName', $target.val()

        changeDatabasePort: (event) ->
            $target = $ event.currentTarget
            if not $target.parsley 'validate' then return

            @resModel.set 'port', $target.val()

        changePublicAccessCheck: (event) ->

            value = event.target.checked
            @resModel.set 'accessible', value

        changeVersionUpdate: (event) ->

            value = event.target.checked
            @resModel.set 'autoMinorVersionUpgrade', value

        changeAutoBackupCheck: (event) ->

            value = if event.target.checked then '1' else '0'
            @changeBackupPeriod(null, value)

        changeBackupPeriod: (event, value) ->

            if event #trigger by event
                $target = $ event.currentTarget
                if not $target.parsley 'validate' then return
                value = $target.val()
            else if value
                #invokie by manual
                $("#property-dbinstance-backup-period").val( value ).parsley 'validate'
            else
                console.error "at least one value in event or value"
                return null

            #show/hide input
            if value isnt '0'
                $("#group-dbinstance-backup-period").removeClass('hide')
                $('#property-dbinstance-auto-backup-group').removeClass('hide')
            else
                $("#group-dbinstance-backup-period").addClass('hide')
                $('#property-dbinstance-auto-backup-group').addClass('hide')

            #update model
            @resModel.autobackup Number(value) #setter

        changeBackupOption: (event) ->

            $backupGroup = $('#property-dbinstance-backup-window-group')
            selectedValue = $(event.currentTarget).val()
            if selectedValue is 'window'
                $backupGroup.show()
                @changeBackupTime()
            else
                $backupGroup.hide()
                @resModel.set('backupWindow', '')

        changeMaintenanceOption: (event) ->

            $maintenanceGroup = $('#property-dbinstance-maintenance-window-group')
            selectedValue = $(event.currentTarget).val()
            if selectedValue is 'window'
                $maintenanceGroup.show()
                @changeMaintenanceTime()
            else
                $maintenanceGroup.hide()
                @resModel.set('maintenanceWindow', '')

        changeBackupTime: (event) ->
            if $('#property-dbinstance-backup-window-start-time').parsley 'validate'
                @_setBackupTime()

        changeMaintenanceTime: (event) ->
            if $('#property-dbinstance-maintenance-window-start-time').parsley 'validate'
                @_setMaintenanceTime()

        getInstanceStatus: () ->

            _setStatus = (showError) ->

                $('.property-dbinstance-status-icon-warning').remove()
                that.setTitle(that.appModel.get('name'))
                if showError is true
                    $('.db-status-loading').remove()
                    $('.property-dbinstance-not-available-info').show()
                    tip = '<i class="property-dbinstance-status-icon-warning icon-warning"></i>'
                else if showError is false
                    $('.db-status-loading').remove()
                    tip = ''
                else
                    tip = '<div class="db-status-loading loading-spinner loading-spinner-small"></div>'
                that.prependTitle tip

            that = this
            dbId = @appModel.get('DBInstanceIdentifier')
            _setStatus()

            region = Design.instance().region()
            ApiRequest('rds_ins_DescribeDBInstances', {
                id: dbId,
                region_name: region
            }).then (data) ->

                data = data.DescribeDBInstancesResponse.DescribeDBInstancesResult.DBInstances?.DBInstance || []
                dbData = if not _.isArray(data) then data else data[0]

                if dbData

                    dbStatus = dbData.DBInstanceStatus
                    if dbStatus isnt 'available'
                        _setStatus(true)
                        return

                _setStatus(false)

            , () ->

                _setStatus(false)

    }

    new DBInstanceView()
