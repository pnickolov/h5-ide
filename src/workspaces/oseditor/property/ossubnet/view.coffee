define [
  'constant'
  '../OsPropertyView'
  './stack'
], ( constant, OsPropertyView, stackTpl ) ->

    OsPropertyView.extend {

        events:

            'select_dropdown_close select': 'onClick'

        render: ->

            @$el.html stackTpl({})
            @

        selectTpl:

            ABC: (item) ->

                return '<div>XXX ' + item.text + '</div>'

            DEF: (item) ->

                return '<div>XXX ' + item.text + '</div>'

            HIJ: () ->

                return '<div>Add...</div>'

        onClick: (event) ->

            $(event.target)[0].selectize.setLoading(true);
            $(event.target)[0].selectize.setLoading(false);

    }, {
        handleTypes: [ constant.RESTYPE.OSSUBNET ]
        handleModes: [ 'stack', 'appedit' ]
    }