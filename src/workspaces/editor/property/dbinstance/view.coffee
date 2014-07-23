#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         'og_dropdown'
         './template/stack_instance'
         './template/stack_replica'
         './template/stack_component'
         'i18n!/nls/lang.js'
         'constant'
         'CloudResources'
         'rds_pg'
], ( PropertyView, OgDropdown, template_instance, template_replica, template_component, lang, constant, CloudResources, parameterGroup ) ->

    noop = ()-> null

    DBInstanceView = PropertyView.extend {

        events:
            'change #property-dbinstance-name': 'changeInstanceName'
            'change #property-dbinstance-mutil-az-check': 'changeMutilAZ'
            'change #property-dbinstance-storage': 'changeAllocatedStorage'
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
            @renderLVIA()

        _getTimeData: (timeStr) ->
            try
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

                return {
                    startHour: startHour,
                    startMin: startMin,
                    startTime: "#{startHour}:#{startMin}",
                    duration: duration,
                    startWeek: startWeekStr
                }

            catch err

                return {
                    startHour: '00',
                    startMin: '00',
                    startTime: "00:00",
                    duration: 0.5,
                    startWeek: 'Mondey'
                }

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

            attr

        render: () ->

            attr = @getModelJSON()

            backupTime = @_getTimeData(attr.backupWindow)
            maintenanceTime = @_getTimeData(attr.maintenanceWindow)

            attr.backup = backupTime
            attr.maintenance = maintenanceTime
            attr.backupDurations = @genDuration backupTime.duration
            attr.maintenanceDurations = @genDuration maintenanceTime.duration

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
            template = template_instance if attr.snapshotId

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
            @renderLVIA()
            @renderOptionGroup()

            # set Start Day week selection
            weekStr = maintenanceTime?.startWeek
            if weekStr
                $select = $('#property-dbinstance-maintenance-window-start-day-select')
                $item = $select.find(".item[data-id='#{weekStr}']").addClass('selected')
                $select.find('.selection').text($item.text())

            @resModel.get 'name'

            @pgDropdown = new parameterGroup(@resModel).renderDropdown()

            $("#property-dbinstance-parameter-group-select").html(@pgDropdown.el)

            @bindParsley()

            attr.name

        bindParsley: ->
            validateStartTime = (val) ->
                if not /^(([0-1][0-9])|(2[0-3])):[0-5][0-9]$/.test val
                        'Format error, the right format is 00:00.'

            $('#property-dbinstance-backup-window-start-time').parsley 'custom', validateStartTime
            $('#property-dbinstance-maintenance-window-start-time').parsley 'custom', validateStartTime



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

        renderParameterGroup: ->
            #close dropdown
            Canvon(".selectbox.combo-dd.multiopen").removeClass("open")
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
            _.extend data, attr

            $('#lvia-container').html template_component.lvi(data)

            spec = @resModel.getSpecifications()
            lvi = @resModel.getLVIA spec
            multiAZCapable = lvi[3]

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

            if @checkResName(target, 'DBInstance')

                value = target.val()

                target.parsley 'custom', ( val ) ->

                    errTip = 'DB Instance name invalid'
                    if (val[val.length - 1]) is '-' or (val.indexOf('--') isnt -1)
                        return errTip
                    if val.length > 10 and that.resModel.isSqlserver()
                        return errTip
                    if val.length > 58
                        return errTip
                    if not MC.validate('letters', val[0])
                        return errTip

                if target.parsley 'validate'

                    @resModel.setName value
                    @setTitle value
                    @resModel.set 'instanceId', value

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

        changeAllocatedStorage: (event) ->

            that = this
            target = $(event.target)
            value = target.val()

            target.parsley 'custom', (val) ->

                storage = Number(value)

                if that.resModel.isMysql() and not (storage >=5 and storage <= 3072)
                    return 'Must be an integer from 5 to 3072'

                if that.resModel.isPostgresql() and not (storage >=5 and storage <= 3072)
                    return 'Must be an integer from 5 to 3072'

                if that.resModel.isOracle() and not (storage >=10 and storage <= 3072)
                    return 'Must be an integer from 10 to 3072'

                if that.resModel.isSqlserver()
                    engine = that.resModel.get('engine')
                    if engine in ['sqlserver-ee', 'sqlserver-se'] and not (storage >=200 and storage <= 1024)
                        return 'Must be an integer from 200 to 1024'
                    if engine in ['sqlserver-ex', 'sqlserver-web'] and not (storage >=30 and storage <= 1024)
                        return 'Must be an integer from 30 to 1024'

            if target.parsley 'validate'
                that.resModel.set 'allocatedStorage', Number(value)

        _getIOPSRange: (storage) ->

            if @resModel.isSqlserver()
                minIOPS = maxIOPS = storage * 10
            else
                minIOPS = Math.max(1000, storage * 3)
                maxIOPS = storage * 10

            return {
                minIOPS: minIOPS
                maxIOPS: maxIOPS
            }

        changeProvisionedIOPSCheck: (event) ->

            value = event.target.checked

            storage = Number($('#property-dbinstance-storage').val())
            iopsRange = @_getIOPSRange(storage)

            if value
                $('.property-dbinstance-iops-value-section').show()
                $('#property-dbinstance-iops-value').val(iopsRange.minIOPS)
                @resModel.setIops iopsRange.minIOPS
            else
                $('.property-dbinstance-iops-value-section').hide()
                $('#property-dbinstance-iops-value').val('')
                @resModel.setIops ''

        changeProvisionedIOPS: (event) ->

            that = this
            target = $(event.target)
            value = target.val()
            iops = Number(value)

            storage = Number($('#property-dbinstance-storage').val())
            iopsRange = @_getIOPSRange(storage)

            target.parsley 'custom', (val) ->
                iops = Number(val)
                if iops >= iopsRange.minIOPS and iops <= iopsRange.maxIOPS
                    return null
                if iopsRange.minIOPS is iopsRange.maxIOPS
                    return "Require #{iopsRange.minIOPS} IOPS"
                else
                    return "Require #{iopsRange.minIOPS}-#{iopsRange.maxIOPS} IOPS"

            if target.parsley 'validate'
                @resModel.setIops Number(iops)

        changeUserName: (event) ->

            that = this
            target = $(event.target)
            value = target.val()

            target.parsley 'custom', (val) ->
                if MC.validate('alphanum', val) and MC.validate('letters', val[0])
                    if that.resModel.isMysql() and val.length >= 1 and val.length <= 16
                        return null
                    if that.resModel.isOracle() and val.length >= 1 and val.length <= 30
                        return null
                    if that.resModel.isSqlserver() and val.length >= 1 and val.length <= 128
                        return null
                    if that.resModel.isPostgresql() and val.length >= 2 and val.length <= 16
                        return null
                return "Invalid username"

            if target.parsley 'validate'
                @resModel.set 'username', value

        changePassWord: (event) ->

            that = this
            target = $(event.target)
            value = target.val()

            target.parsley 'custom', (val) ->
                if that.resModel.isMysql() and val.length >= 8 and val.length <= 41
                    return null
                if that.resModel.isOracle() and val.length >= 8 and val.length <= 30
                    return null
                if that.resModel.isSqlserver() and val.length >= 8 and val.length <= 128
                    return null
                if that.resModel.isPostgresql() and val.length >= 8 and val.length <= 128
                    return null
                return 'Invalid password'

            if target.parsley 'validate'
                @resModel.set 'password', value

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
                Canvon("#group-dbinstance-backup-period").removeClass('hide')
                $('#property-dbinstance-auto-backup-group').removeClass('hide')
            else
                Canvon("#group-dbinstance-backup-period").addClass('hide')
                $('#property-dbinstance-auto-backup-group').addClass('hide')

            #update model
            @resModel.autobackup Number(value) #setter

        changeBackupOption: (event) ->

            $backupGroup = $('#property-dbinstance-backup-window-group')
            selectedValue = $(event.currentTarget).val()
            if selectedValue is 'window'
                $backupGroup.show()
            else
                $backupGroup.hide()
                @resModel.set('backupWindow', '')


        changeMaintenanceOption: (event) ->

            $maintenanceGroup = $('#property-dbinstance-maintenance-window-group')
            selectedValue = $(event.currentTarget).val()
            if selectedValue is 'window'
                $maintenanceGroup.show()
            else
                $maintenanceGroup.hide()
                @resModel.set('maintenanceWindow', '')

        changeBackupTime: (event) ->
            if $('#property-dbinstance-backup-window-start-time').parsley 'validate'
                @_setBackupTime()

        changeMaintenanceTime: (event) ->
            if $('#property-dbinstance-maintenance-window-start-time').parsley 'validate'
                @_setMaintenanceTime()

    }

    new DBInstanceView()
