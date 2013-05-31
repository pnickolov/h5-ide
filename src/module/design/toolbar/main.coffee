####################################
#  Controller for design/toolbar module
####################################

define [ 'jquery', 'text!/module/design/toolbar/template.html', 'event' ], ( $, template, event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="toolbar-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#main-toolbar'

        #load remote module1.js
        require [ './module/design/toolbar/view' ], ( View ) ->

            #view
            view       = new View()
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule