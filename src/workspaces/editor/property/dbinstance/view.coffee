#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         'og_dropdown'
         './template/stack_instance'
         './template/stack_replica'
         './template/stack_snapshot'
         './template/stack_component'
         'i18n!/nls/lang.js'
         'constant'
         'CloudResources'
         'rds_pg'
], ( PropertyView, OgDropdown, template_instance, template_replica, template_snapshot, template_component, lang, constant, CloudResources, parameterGroup ) ->

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

            'change #property-dbinstance-backup-window-start-hour': 'changeBackupTime'
            'change #property-dbinstance-backup-window-start-minute': 'changeBackupTime'
            'change #property-dbinstance-backup-window-duration': 'changeBackupTime'

            'OPTION_CHANGE #property-dbinstance-maintenance-window-start-day-select': 'changeMaintenanceTime'
            'change #property-dbinstance-maintenance-window-duration': 'changeMaintenanceTime'
            'change #property-dbinstance-maintenance-window-start-hour': 'changeMaintenanceTime'
            'change #property-dbinstance-maintenance-window-start-minute': 'changeMaintenanceTime'

            'OPTION_CHANGE #property-dbinstance-license-select': 'changeLicense'
            'OPTION_CHANGE #property-dbinstance-engine-version-select': 'changeVersion'
            'OPTION_CHANGE #property-dbinstance-class-select': 'changeClass'
            'OPTION_CHANGE #property-dbinstance-preferred-az': 'changeAZ'

            'OPTION_CHANGE #property-dbinstance-charset-select': 'changeCharset'

        changeCharset: ( event, value ,data ) ->
            @model.set 'characterSetName', value

        changeLicense: ( event, value, data ) ->
            @model.set 'license', value
            @renderLVIA()

        changeVersion: ( event, value, data ) ->
            @model.set 'engineVersion', value
            @renderLVIA()

        changeClass: ( event, value, data ) ->
            @model.set 'instanceClass', value
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
                    duration: duration,
                    startWeek: startWeekStr
                }

            catch err

                return null

        _getTimeStr: (startHour, startMin, duration, startWeek) ->

            addZero = (num) ->

                numStr = String(num)
                if numStr.length is 1
                    numStr = '0' + numStr
                return numStr

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

        _setBackupTime: () ->

            hour = Number($('#property-dbinstance-backup-window-start-hour').val())
            min = Number($('#property-dbinstance-backup-window-start-minute').val())
            duration = Number($('#property-dbinstance-backup-window-duration').val())
            timeStr = @_getTimeStr(hour, min, duration)
            @model.set('backupWindow', timeStr)

        _setMaintenanceTime: () ->

            hour = Number($('#property-dbinstance-maintenance-window-start-hour').val())
            min = Number($('#property-dbinstance-maintenance-window-start-minute').val())
            duration = Number($('#property-dbinstance-maintenance-window-duration').val())
            week = $('#property-dbinstance-maintenance-window-start-day-select').find('.item.selected').data('id')
            timeStr = @_getTimeStr(hour, min, duration, week)
            @model.set('maintenanceWindow', timeStr)

        render: () ->

            attr = @model.toJSON()

            backupTime = @_getTimeData(attr.backupWindow) or {}
            maintenanceTime = @_getTimeData(attr.maintenanceWindow) or {}

            attr.backup = backupTime
            attr.maintenance = maintenanceTime


            spec = @model.getSpecifications()
            lvi = @model.getLVIA spec

            attr.licenses = lvi[0]
            attr.versions = lvi[1]
            attr.classes  = lvi[2]

            template = template_instance
            # if replica
            template = template_replica if attr.replicaId
            # if snapshot
            template = template_snapshot if attr.snapshotId

            # if oracle
            if attr.engine.indexOf('oracle') is 0
                attr.isOracle = true
                attr.oracleCharset = _.map Design.modelClassForType(constant.RESTYPE.DBINSTANCE).oracleCharset, (oc) ->
                    charset: oc, selected: oc is attr.characterSetName

            @$el.html template attr
            @renderLVIA()

            # init option group
            $ogDropdown = @$el.find('.property-dbinstance-optiongroup-placeholder')
            ogDropdown = new OgDropdown({
                el: $ogDropdown
            })
            $ogDropdown.html ogDropdown.render({
                    engine: attr.engine,
                    version: @model.getMajorVersion()
                }).el

            # set Start Day week selection
            weekStr = maintenanceTime.startWeek
            if weekStr
                $select = $('#property-dbinstance-maintenance-window-start-day-select')
                $item = $select.find(".item[data-id='#{weekStr}']").addClass('selected')
                $select.find('.selection').text($item.text())

            # set preferred AZ list
            region = Design.instance().get('region')
            allAZComp = CloudResources( constant.RESTYPE.AZ, region ).where({category:region}) || []
            allAZ = []
            allAZName = []
            _.each allAZComp, (az) ->
                allAZ.push({
                    name: az.id
                })
                allAZName.push(az.id)
                null
            $('#property-dbinstance-preferred-az').html template_component.preferred_az(allAZ)
            if attr.az and (attr.az in allAZName)
                selectedAZ = attr.az
            else
                selectedAZ = 'no'
            $preferredAZSelect = $('#property-dbinstance-preferred-az')
            $item = $preferredAZSelect.find(".item[data-id='#{selectedAZ}']").addClass('selected')
            $preferredAZSelect.find('.selection').text($item.text())

            @model.get 'name'

            @pgDropdown = new parameterGroup(@model).renderDropdown()

            $("#property-dbinstance-parameter-group-select").html(@pgDropdown.el)
        # Render License, Version, InstanceClass and multi-AZ
        renderLVIA: ->
            spec = @model.getSpecifications()
            lvi  = @model.getLVIA spec

            data = {
                licenses : lvi[0]
                versions : lvi[1]
                classes  : lvi[2]
                azCapable: lvi[3]
            }
            _.extend data, @model.toJSON()

            $('#lvia-container').html template_component.lvi(data)
            @

        changeInstanceName: (event) ->
            value = $(event.target).val()
            @model.setName value
            @setTitle value
            @model.set 'instanceId', value
            null

        changeMutilAZ: (event) ->

            value = event.target.checked
            $select = $('.property-dbinstance-preferred-az')
            if value
                $select.find('.item').remove('selected')
                $item = $select.find(".item[data-id='no']").addClass('selected')
                $select.find('.selection').text($item.text())
                $select.hide()
                @model.set 'az', ''
            else
                $select.show()

            @model.set 'multiAz', value

        changeAZ: ( event, name, data ) ->

            if name is 'no'
                @model.set 'az', ''
            else
                @model.set 'az', name

            @renderLVIA()

        changeAllocatedStorage: (event) ->

            value = $(event.target).val()
            @model.set 'allocatedStorage', Number(value)

        changeProvisionedIOPSCheck: (event) ->

            value = event.target.checked
            if value
                $('.property-dbinstance-iops-value-section').show()
                $('#property-dbinstance-iops-value').val('100')
                @model.set 'iops', 100
            else
                $('.property-dbinstance-iops-value-section').hide()
                $('#property-dbinstance-iops-value').val('')
                @model.set 'iops', ''

        changeProvisionedIOPS: (event) ->

            value = $(event.target).val()
            @model.set 'iops', Number(value)

        changeUserName: (event) ->

            value = $(event.target).val()
            @model.set 'username', value

        changePassWord: (event) ->

            value = $(event.target).val()
            @model.set 'password', value

        changeDatabaseName: (event) ->

            value = $(event.target).val()
            @model.set 'dbName', value

        changeDatabasePort: (event) ->

            value = $(event.target).val()
            @model.set 'port', value

        changePublicAccessCheck: (event) ->

            value = event.target.checked
            @model.set 'accessible', value

        changeVersionUpdate: (event) ->

            value = event.target.checked
            @model.set 'autoMinorVersionUpgrade', value

        changeAutoBackupCheck: (event) ->

            value = if event.target.checked then '1' else '0'
            @changeBackupPeriod(null, value)

        changeBackupPeriod: (event, value) ->

            if event
                #trigger by event
                value = $(event.target).val()
                #show/hide checkbox
                checked = if Number(value) then true else false
                $("#property-dbinstance-auto-backup-check")
                    .prop("checked",checked)
                    .attr("checked",checked)
            else if value
                #invokie by manual
                $("#property-dbinstance-backup-period").val( value )
            else
                console.error "at least one value in event or value"
                return null

            #show/hide input
            if value isnt '0'
                Canvon("#group-dbinstance-backup-period").removeClass('hide')
            else
                Canvon("#group-dbinstance-backup-period").addClass('hide')

            #update model
            @model.autobackup Number(value) #setter

        changeBackupTime: (event) ->

            @_setBackupTime()

        changeMaintenanceTime: (event) ->

            @_setMaintenanceTime()

    }

    new DBInstanceView()
