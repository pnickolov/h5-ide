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

            if @mode() in ['stack', 'appedit']
                console.log @model
                subnets = @model.connectionTargets("OsRouterAsso")
                json = @model.toJSON()
                json.subnets = _.map subnets, (e)->
                    e.toJSON()

                if @mode() is 'appedit'
                    resData = @getRenderData()
                    _.extend(json, resData) if resData
                    json.status = resData?.app?.status

                extNetwork = @model.getDefaultExt()
                if extNetwork
                    json.extnetwork_name = extNetwork.get('name')
                    json.extnetwork_id = extNetwork.id

                @$el.html template.stackTemplate json
            else
                @$el.html template.appTemplate @getRenderData()
            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            if attr is 'gateway'

                if value is true
                    @$el.find('.os-property-router-extnetwork').removeClass('hide')
                    @$el.find('.os-property-router-nat').removeClass('hide')
                    @model.attachToExt()
                else
                    @$el.find('.os-property-router-extnetwork').addClass('hide')
                    @$el.find('.os-property-router-nat').addClass('hide')
                    @model.unattachToExt()

                    # set nat to false
                    @$el.find('.selection[data-target="nat"]').setValue(false)
                    @model.set('nat', false)

            if attr in ['name', 'nat']
                @model.set(attr, value)

            @setTitle(value) if attr is 'name'

    }, {
        handleTypes: [ constant.RESTYPE.OSRT ]
        handleModes: [ 'stack', 'appedit', 'app' ]
    }
