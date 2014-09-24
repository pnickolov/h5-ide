define [
    'constant'
    '../OsPropertyView'
    '../osport/view'
    './template/app'


], ( constant, OsPropertyView, portView, template ) ->

    OsPropertyView.extend {

        render: ->
            @$el.html template @getRenderData()
            @$el.append @reg( new portView model: @model, appModel: @genModelForPort() ).render().el
            @

        genModelForPort: ->
            appJson = @appModel.toJSON()

            json = _.pick appJson,
                'status'
                'subnet_id'
                'address'
                'connection_limit'
                'protocol'
                'protocol_port'
                'pool_id'

            json.id = appJson.port_id

            new Backbone.Model json




    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
        handleModes: [ 'app' ]
    }
