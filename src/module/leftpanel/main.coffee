
define [ 'jquery', 'text!./module/leftpanel/template.html' ], ( $, template ) ->
    
    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="leftpanel-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo 'head'

        #load remote module1.js
        require [ './module/leftpanel/view' ], ( View ) ->

            #view
            view       = new View()
            view.render()

    #public
    loadModule : loadModule