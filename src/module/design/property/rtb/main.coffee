####################################
#  Controller for design/property/rtb module
####################################

define [ '../base/main',
         './model'
], ( PropertyModule, model, view, app_model, app_view, ide_event, constant ) ->

    ideEvents = {}
    ideEvents[ ide_event.CANVAS_DELETE_OBJECT ] = () ->
        this.model.reInit()
        this.view.render()

    ideEvents[ ide_event.CANVAS_CREATE_LINE ] = () ->
        this.model.reInit()
        this.view.render()

    RTBModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

        setupStack : () ->

            me = this
            @view.on 'SET_ROUTE', ( uid, data, routes ) ->
                me.model.setRoutes uid, data, routes

            @view.on 'SET_NAME', ( uid, name ) ->
                me.model.setName uid, name

            @view.on 'SET_MAIN_RT', ( uid ) ->
                me.model.setMainRT uid
                me.model.reInit()

            @view.on 'SET_PROPAGATION', ( uid, value ) ->
                me.model.setPropagation uid, value

        initStack : () ->
            @model = model
            @view  = view
            null

        initApp  : () ->
            @model = app_model
            @view  = app_view
            null

    }
    null
