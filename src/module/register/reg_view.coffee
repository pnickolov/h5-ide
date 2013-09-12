#############################
#  View(UI logic) for register
#############################

define [ 'event', 'text!./reg_template.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, reg_tmpl ) ->

    RegisterView = Backbone.View.extend {

        el       :  '#container'

        template : Handlebars.compile reg_tmpl

        #events   :

        initialize : ->
            #

        render   : () ->
            console.log 'register render'
            @$el.html @template @model

    }

    return RegisterView
