####################################
#  Controller for header module
####################################

define [ 'jquery', 'text!/module/header/template.html' ], ( $, template ) ->

    view = null

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="header-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#header'

        #load remote module1.js
        require [ './module/header/view', './module/header/model' ], ( View, model ) ->

            #view
            view       = new View()

            #event
            view.on 'BUTTON_LOGOUT_CLICK', () ->

                model.logout()


            view.render()

    unLoadModule = () ->
        #

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule