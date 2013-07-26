#############################
#  View(UI logic) for dialog
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    HeaderView = Backbone.View.extend {

        el       : $( '#header' )

        template : Handlebars.compile $( '#header-tmpl' ).html()

        events   :
            'click #btn-logout'                : 'clickLogout'

        render   : () ->
            console.log 'header render'
            $( this.el ).html this.template()
            event.trigger event.HEADER_COMPLETE

        clickLogout : () ->

            this.trigger 'BUTTON_LOGOUT_CLICK'

    }

    return HeaderView