define [
    'constant'
    '../OsPropertyView'
    '../osport/view'
    './template/app'
    'CloudResources'


], ( constant, OsPropertyView, portView, template, CloudResources ) ->

    OsPropertyView.extend {

        render: ->
            @$el.html template @getRenderData()
            @$el.append @reg( new portView model: @model, appModel: @genModelForPort() ).render().el
            @

        genModelForPort: ->
            region = Design.instance().region()
            portId = @appModel.get 'port_id'

            CloudResources( constant.RESTYPE.OSPORT, region ).get portId





    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
        handleModes: [ 'app' ]
    }
