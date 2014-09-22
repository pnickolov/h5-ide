define [
  'constant'
  '../OsPropertyView'
  './template'
], ( constant, OsPropertyView, template ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]" : "updateAttribute"

        render: ->

            if @mode in ['stack', 'appedit']
                json = @model.toJSON()
                if @mode is 'appedit'
                    json = _.extend(json, @getRenderData())
                @$el.html template.stack()
            else
                @$el.html template.app @getRenderData()
            @

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }
