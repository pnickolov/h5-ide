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

        render: () ->
            @$el.html template @model.toJSON()

        changeInstanceName: (event) ->

            value = $(event.target).val()
            @model.set 'instanceId', value
            @model.set 'name', value

            null

        changeMutilAZ: (event) ->

            @model.set 'multiAz', event.target.checked

        changeAllocatedStorage: (event) ->

            value = $(event.target).val()
            @model.set 'allocatedStorage', value

        changeProvisionedIOPSCheck: (event) ->

            value = event.target.checked
            if value
                $('.property-dbinstance-iops-value-section').show()
                $('#property-dbinstance-iops-value').val('100')
                @model.set 'iops', '100'
            else
                $('.property-dbinstance-iops-value-section').hide()
                $('#property-dbinstance-iops-value').val('')
                @model.set 'iops', ''

        changeProvisionedIOPS: (event) ->

            value = $(event.target).val()
            @model.set 'iops', value

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

    }

    new DBInstanceView()