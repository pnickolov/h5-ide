#############################
#  View(UI logic) for register
#############################

define [ 'event',
         'text!./template.html', 'text!./success.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, success_tmpl ) ->

    RegisterView = Backbone.View.extend {

        el       :  '#container'

        template     : Handlebars.compile tmpl
        success_tmpl : Handlebars.compile success_tmpl

        #events   :

        initialize : ->
            #

        render   : ( type ) ->
            console.log 'register render'
            console.log type

            switch type
                when 'normal'
                    @$el.html @template @model
                when 'success'
                    @$el.html @success_tmpl()
                else
                    @$el.html @template @model

    }

    return RegisterView
