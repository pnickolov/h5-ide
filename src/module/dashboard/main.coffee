####################################
#  Controller for dashboard module
####################################

define [ 'jquery', 'text!/module/dashboard/template.html' ], ( $, template ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="dashboard-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#tab-content-dashboard'

        #load remote module1.js
        require [ './module/dashboard/view' ], ( View ) ->

            #view
            view       = new View()
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule