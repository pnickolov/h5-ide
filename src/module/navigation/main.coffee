####################################
#  Controller for navigation module
####################################

define [ 'jquery', 'text!/module/navigation/template.html', 'app_model' ], ( $, template, app_model ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="navigation-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo 'head'

        #get service(model)
        console.log 'fefwewerqwrqwerqwersdfd'
        app_model.info { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), $.cookie( 'region_name' ), null
        app_model.on 'APP_INFO_RETURN', ( event ) ->
            console.log 'APP_INFO_RETURN'
            console.log event

            #load remote module1.js
            require [ './module/navigation/view', 'UI.tooltip', 'UI.scrollbar', 'UI.accordion', 'hoverIntent' ], ( View ) ->

                #view
                view       = new View()
                view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule