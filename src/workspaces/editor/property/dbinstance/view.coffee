#############################
#  View(UI logic) for design/property/dbinstacne
#############################

define [ '../base/view',
         './template/stack',
         'i18n!/nls/lang.js', 'constant' ], ( PropertyView, template, lang, constant ) ->

    noop = ()-> null

    DBInstanceView = PropertyView.extend {

        events:
            '': ''

        render: () ->

            @$el.html template @model.toJSON()

    }

    new DBInstanceView()