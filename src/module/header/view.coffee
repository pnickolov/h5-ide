#############################
#  View(UI logic) for dialog
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    HeaderView = Backbone.View.extend {

        el       : '#header'

        template : Handlebars.compile $( '#header-tmpl' ).html()

        events   :
            'click #btn-logout'                     : 'clickLogout'
            'click #awscredential-modal'            : 'clickOpenAWSCredential'
            'DROPDOWN_CLOSE #header--notification' : 'dropdownClosed'
            'click .dropdown-app-name'              : 'clickAppName'

        render   : () ->
            console.log 'header render'
            $( this.el ).html this.template this.model.attributes
            ide_event.trigger ide_event.HEADER_COMPLETE

        clickLogout : () ->
            this.trigger 'BUTTON_LOGOUT_CLICK'

        dropdownClosed : () ->
            console.log 'dropdown closed'
            this.trigger 'DROPDOWN_MENU_CLOSED'

        clickAppName : (event) ->
            console.log 'click dropdown app name'

            this.trigger 'DROPDOWN_APP_NAME_CLICK', event.currentTarget.id

        clickOpenAWSCredential : () ->
            this.trigger 'AWSCREDENTIAL_CLICK'

        resetAlert : ->
            console.log 'resetAlert'
            $('.notification-counter').text("")

    }

    return HeaderView
