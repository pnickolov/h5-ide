#############################
#  View(UI logic) for register
#############################

define [ 'event',
         'text!./reg_template.html', 'text!./reg_success.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, reg_tmpl, reg_success_tmpl ) ->

    RegisterView = Backbone.View.extend {

        el       :  '#container'

        template     : Handlebars.compile reg_tmpl
        success_tmpl : Handlebars.compile reg_success_tmpl

        #events   :

        initialize : ->
            #

        render   : ( type ) ->
            console.log 'register render'
            console.log type
            if type is 'success'
                @$el.html @success_tmpl()
            else
                @$el.html @template @model

    }

    return RegisterView
