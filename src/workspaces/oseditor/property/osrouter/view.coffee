define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    'underscore'
    'OsKp'
], ( constant, OsPropertyView, template, CloudResources, _, OsKp ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]": "updateAttribute"

        render: ->

            if @mode in ['stack', 'appedit']
                console.log @model
                subnets = @model.connectionTargets("OsRouterAsso")
                json = @model.toJSON()
                json.subnets = _.map subnets, (e)->
                    e.toJSON()

                if @mode is 'appedit'
                    resData = @getRenderData()
                    _.extend(json, resData) if resData
                    json.status = resData?.app?.status

                @$el.html template.stackTemplate json
            else
                @$el.html template.appTemplate @getRenderData()
            @

    }, {
        handleTypes: [ constant.RESTYPE.OSRT ]
        handleModes: [ 'stack', 'appedit', 'app' ]
    }
