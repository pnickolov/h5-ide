#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view'
         './template/stack'
         'i18n!/nls/lang.js'
         'constant'
], ( PropertyView, template, lang, constant ) ->

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
            @model.set('preferredBackupWindow', timeStr)

        _setMaintenanceTime: () ->

            hour = Number($('#property-dbinstance-maintenance-window-start-hour').val())
            min = Number($('#property-dbinstance-maintenance-window-start-minute').val())
            duration = Number($('#property-dbinstance-maintenance-window-duration').val())
            week = $('#property-dbinstance-maintenance-window-start-day-select').find('.item.selected').data('id')
            timeStr = @_getTimeStr(hour, min, duration, week)
            @model.set('preferredMaintenanceWindow', timeStr)

        render: () ->
            attr = @model.toJSON()

            backupTime = @_getTimeData(attr.preferredBackupWindow) or {}
            maintenanceTime = @_getTimeData(attr.preferredMaintenanceWindow) or {}

            attr.backup = backupTime
            attr.maintenance = maintenanceTime

            @$el.html template attr

            # set Start Day week selection
            weekStr = maintenanceTime.startWeek
            if weekStr
                $item = $('#property-dbinstance-maintenance-window-start-day-select').find(".item[data-id='#{weekStr}']")
                $item.addClass('selected')
                $('#property-dbinstance-maintenance-window-start-day-select').find('.selection').text($item.text())

            @model.get 'name'

        changeInstanceName: (event) ->

            value = $(event.target).val()
            @model.set 'instanceId', value
            @model.set 'name', value

            null

        changeMutilAZ: (event) ->

            @model.set 'multiAz', event.target.checked

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

            value = event.target.checked
            if value
                @model.set 'backupRetentionPeriod', 1
                $('#property-dbinstance-backup-period').val('1')
            else
                @model.set 'backupRetentionPeriod', 0
                $('#property-dbinstance-backup-period').val('0')

        changeBackupPeriod: (event) ->

            value = $(event.target).val()
            @model.set 'backupRetentionPeriod', Number(value)

        changeBackupTime: (event) ->

            @_setBackupTime()

        changeMaintenanceTime: (event) ->

            @_setMaintenanceTime()

    }

    new DBInstanceView()
