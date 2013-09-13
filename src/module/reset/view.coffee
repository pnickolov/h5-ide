#############################
#  View(UI logic) for reset
#############################

define [ 'event',
         'text!./template.html', 'text!./password.html', 'text!./success.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, password_tmpl, success_tmpl ) ->

    ResetView = Backbone.View.extend {

        el       :  '#container'

        template      : Handlebars.compile tmpl
        password_tmpl : Handlebars.compile password_tmpl
        success_tmpl  : Handlebars.compile success_tmpl

        #events   :

        initialize : ->
            #

        render   : ( type ) ->
            console.log 'reset render'
            console.log type

            switch type
                when 'normal'
                    @$el.html @template @model
                when 'success'
                    @$el.html @success_tmpl()
                when 'password'
                    @$el.html @password_tmpl @model
                else
                    @$el.html @template @model

    }

    return ResetView
