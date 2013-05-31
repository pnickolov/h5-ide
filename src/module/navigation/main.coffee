####################################
#  Controller for navigation module
####################################

define [ 'jquery', 'text!/module/navigation/template.html' ], ( $, template ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="navigation-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#navigation'

        #load remote module1.js
        require [ './module/navigation/view' ], ( View ) ->

            #view
            view       = new View()
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule