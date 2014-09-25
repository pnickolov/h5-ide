define [
    'constant'
    '../OsPropertyView'
    './template'
    'CloudResources'
    '../ossglist/view'
], ( constant, OsPropertyView, template, CloudResources, SgListView ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]": "updateAttribute"

        initialize: ->
            @sgListView = @reg new SgListView targetModel: @model

        render: ->

            if @mode() in ['stack', 'appedit']

                if @model.isAttached()
                    value = _.extend {
                        hasFloatIP: @model.getFloatingIp()
                        isPurePort: @model.type is constant.RESTYPE.OSPORT
                    }, @model.toJSON()
                    if @mode() is 'appedit'
                        value = _.extend(value, @getRenderData())
                    @$el.html template.stack(value)
                else
                    @$el.html template.unattached(value)

            else

                # get float ip
                extendData = {}
                floatIPModel = @model.getFloatingIp()
                if floatIPModel
                    floatIPData = CloudResources(constant.RESTYPE.OSFIP, Design.instance().region()).get(floatIPModel.get('appId'))
                    float_ip = floatIPData.get('floating_ip_address') if floatIPData
                    extendData.float_ip = float_ip
                @$el.html template.app _.extend(@getRenderData(), extendData)

            # append sglist
            @$el.append @sgListView.render().el

            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            if attr is 'float_ip'
                @model.setFloatingIp(value)
            else
                @model.set(attr, value)

            @setTitle(value) if attr is 'name'

        }, {
            handleTypes: [ constant.RESTYPE.OSPORT ]
            handleModes: [ 'stack', 'app', 'appedit' ]
        }
