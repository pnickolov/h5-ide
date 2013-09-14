#############################
#  View(UI logic) for reset
#############################

define [ 'event',
         'text!./template.html', 'text!./password.html', 'text!./email.html', 'text!./success.html',
         'backbone', 'jquery', 'handlebars' ], ( ide_event, tmpl, password_tmpl, email_tmpl, success_tmpl ) ->

    ResetView = Backbone.View.extend {

        el       :  '#container'

        template      : Handlebars.compile tmpl
        password_tmpl : Handlebars.compile password_tmpl
        email_tmpl    : Handlebars.compile email_tmpl
        success_tmpl  : Handlebars.compile success_tmpl

        events   :
            'click #reset-btn' : 'resetButtonEvent'

        initialize : ->
            #

        render   : ( type ) ->
            console.log 'reset render'
            console.log type

            switch type
                when 'normal'
                    @$el.html @template @model
                when 'password'
                    @$el.html @password_tmpl @model
                when 'email'
                    @$el.html @email_tmpl @model
                when 'success'
                    @$el.html @success_tmpl()
                else
                    @$el.html @template @model

        resetButtonEvent : ->
            console.log 'resetButtonEvent'
            this.trigger 'RESET_EMAIL', $( '#reset-pw-email' ).val()
            false

    }

    return ResetView
