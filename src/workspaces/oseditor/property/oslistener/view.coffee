define [
    'constant'
    '../OsPropertyView'
    '../osport/view'
    './template/stack'
    'CloudResources'

], ( constant, OsPropertyView, portView, template, CloudResources ) ->

    OsPropertyView.extend {

        events:
            'change [data-target]': 'updateAttribute'

        render: ->
            @$el.html template @getRenderData()
            region = Design.instance().region()

            @$el.append @reg( new portView {
                model: @model,
                appModel: CloudResources( constant.RESTYPE.OSPORT, region ).get( @model.get 'portId' )
            } ).render().el
            @

        getModelForUpdateAttr: ( e ) ->
            $target = $ e.currentTarget
            dataModel = $target.closest( '[data-model]' ).data 'model'
            if dataModel is 'listener' then @model else null

    }, {
        handleTypes: [ constant.RESTYPE.OSLISTENER ]
        handleModes: [ 'stack', 'appedit' ]
    }
