define [
  'constant'
  '../OsPropertyView'
  './stack'
], ( constant, OsPropertyView, stackTpl ) ->

    OsPropertyView.extend {

        events:
            "change [data-target]" : "updateAttribute"

        render: ->
            @$el.html stackTpl( @model.toJSON() )
            @

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'appedit' ]
    }
