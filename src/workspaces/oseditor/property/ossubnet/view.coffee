define [
  'constant'
  '../OsPropertyView'
  './template'
], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]" : "updateAttribute"

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
