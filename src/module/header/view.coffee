#############################
#  View(UI logic) for dialog
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    HeaderView = Backbone.View.extend {

        el       : $( '#header' )

        template : Handlebars.compile $( '#header-tmpl' ).html()

        events   :
            'click #btn-logout'                     : 'clickLogout'
            'DROPDOWN_CLOSED #header--notification' : 'dropdownClosed'
            'click .dropdown-app-name'              : 'clickAppName'

        render   : () ->
            console.log 'header render'
            $( this.el ).html this.template this.model.attributes
            event.trigger event.HEADER_COMPLETE

        reRender : () ->
            console.log 'header rerender'
            $( this.el ).html this.template this.model.attributes

        clickLogout : () ->

            this.trigger 'BUTTON_LOGOUT_CLICK'

        dropdownClosed : () ->
            console.log 'dropdown closed'

        clickAppName : (event) ->
            console.log 'click dropdown app name'

            this.trigger 'DROPDOWN_APP_NAME_CLICK', event.currentTarget.id

    }

    return HeaderView