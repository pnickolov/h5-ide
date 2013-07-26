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
            $( this.el ).html this.template this.model.attributes
            event.trigger event.HEADER_COMPLETE

<<<<<<< HEAD
        reRender : () ->
            console.log 'header rerender'
            $( this.el ).html this.template this.model.attributes
=======
        clickLogout : () ->

            this.trigger 'BUTTON_LOGOUT_CLICK'
>>>>>>> origin/develop

    }

    return HeaderView