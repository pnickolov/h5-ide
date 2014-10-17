define [
  'constant'
  '../OsPropertyView'
  './template'
], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]" : "updateAttribute"

        initialize: () ->

            @validMap =

                cidr:

                    limit: '^[0-9./]*$'

                    valid: (value) ->

                        cidrRegx = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/(\d|[1-2]\d|3[0-2]))$/
                        return false if not cidrRegx.test(value)
                        return true

        render: ->

            if @mode() in ['stack', 'appedit']
                json = @model.toJSON()
                if @mode() is 'appedit'
                    json = _.extend(json, @getRenderData())
                @$el.html template.stack(json)
            else
                @$el.html template.app @getRenderData()
            @

        updateAttribute: (event)->

            $target = $(event.currentTarget)

            attr = $target.data 'target'
            value = $target.getValue()

            @model.set(attr, value)
            if attr is 'cidr'
                @model.resetAllChildIP()

            @setTitle(value) if attr is 'name'

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }
