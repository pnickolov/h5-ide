####################################
#  Controller for design/property/launchconfig module
####################################

define [ '../base/main',
         './model',
         './view',
         'constant'
], ( PropertyModule, model, view, constant ) ->

    AsgModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

        setupStack : () ->
            me = this

            @view.on 'SET_SNS_OPTION', ( checkArray ) ->
                me.model.setSNSOption checkArray

            @view.on 'SET_TERMINATE_POLICY', ( policies ) ->
                me.model.setTerminatePolicy policies

            @view.on 'SET_HEALTH_TYPE', ( type ) ->
                me.model.setHealthCheckType type

            @view.on 'SET_ASG_NAME', ( name ) ->
                me.model.setASGName name

            @view.on 'SET_ASG_MIN', ( value ) ->
                me.model.setASGMin value

            @view.on 'SET_ASG_MAX', ( value ) ->
                me.model.setASGMax value

            @view.on 'SET_DESIRE_CAPACITY', ( value ) ->
                me.model.setASGDesireCapacity value

            @view.on 'SET_COOL_DOWN', ( value ) ->
                me.model.setASGCoolDown value

            @view.on 'SET_HEALTH_CHECK_GRACE', ( value ) ->
                me.model.setHealthCheckGrace value

            @view.on 'SET_POLICY', ( data ) ->
                me.model.setPolicy data

            @view.on 'DELETE_POLICY', ( uid ) ->
                me.model.delPolicy uid

            null

        initStack : ()->
            @model = model
            @model.isApp = false
            @view  = view
            null

        initApp : ()->
            @model = model
            @model.isApp = false
            @view = view
            null
    }
    null

