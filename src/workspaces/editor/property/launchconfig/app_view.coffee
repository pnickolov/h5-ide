#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view', './template/app' ], ( PropertyView, template ) ->

    LCAppView = PropertyView.extend {

        events:
            'change #property-instance-enable-cloudwatch'   : 'cloudwatchSelect'
            'change #property-instance-user-data'           : 'userdataChange'

        kpModalClosed: false

        render: () ->
            data = @model.toJSON()
            @$el.html template data
            data.name

        cloudwatchSelect : ( event ) ->
            @model.setCloudWatch event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            @model.setUserData event.target.value


    }

    new LCAppView()
