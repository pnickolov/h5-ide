####################################
#  Controller for tabbar module
####################################

define [ 'jquery', 'text!/module/tabbar/template.html' ], ( $, template ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="tabbar-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#tab-bar'

        #load remote module1.js
        require [ './module/tabbar/view' ], ( View ) ->

            #view
            view       = new View()
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule