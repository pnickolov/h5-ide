
define [ 'jquery', 'text!./module/canvas/template.html' ], ( $, template ) ->
    
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="canvas-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo 'head'

        #load remote module1.js
        require [ './module/canvas/view' ], ( View ) ->

            #view
            view = new View()
            view.render()

            # temp -------load ide.js(logic)------- begin
            require [ './module/canvas/canvas' ], ( Canvas ) ->
                Canvas.ready()
            # temp -------load ide.js(logic)------- end

    loadModule : loadModule