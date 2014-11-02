define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
], ( constant, OsPropertyView, template, CloudResources ) ->

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

                console.log CloudResources( constant.RESTYPE.OSNETWORK, Design.instance().region() )

                json.extnetworks = CloudResources( constant.RESTYPE.OSNETWORK, Design.instance().region() ).getExtNetworks().map ( nt )-> nt.id

                @$el.html template.stackTemplate json
            else
                @$el.html template.appTemplate @getRenderData()
            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            if attr is 'extNetworkId'

                if value is "none"
                    value = ""

                natSelection = @$el.find('.selection[data-target="nat"]')

                if value
                    if not @model.get( attr )
                        # set nat to true when toggle to public network
                        natSelection.setValue( true )
                else
                    natSelection.setValue( false )

                @$el.find('.os-property-router-nat').toggleClass('hide', !value)

            # if attr is 'totalBandwidth'
            #     @model.set('totalBandwidth', Number(value))
            # else
            @model.set(attr, value)

            @setTitle(value) if attr is 'name'

    }, {
        handleTypes: [ constant.RESTYPE.OSRT ]
        handleModes: [ 'stack', 'appedit', 'app' ]
    }
