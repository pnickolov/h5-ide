define [
  'constant'
  '../OsPropertyView'
  './stack'
], ( constant, OsPropertyView, stackTpl ) ->

    OsPropertyView.extend {

        render: ->

            @$el.html stackTpl({})
            @

        selectTpl:

          ABC: (item) ->

            return '<div>XXX ' + item.text + '</div>'

          DEF: (item) ->

            return '<div>XXX ' + item.text + '</div>'

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'appedit' ]
    }