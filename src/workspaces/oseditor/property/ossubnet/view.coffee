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
                @$el.html template.stack( @model.toJSON() )
            else
                @$el.html template.app @getRenderData()
            @

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'app', 'appedit' ]
    }
