#############################
#  View(UI logic) for dialog
#############################

define [ 'event',
         'text!/module/process/template.html',
         'backbone', 'jquery', 'handlebars'
], ( ide_event, template ) ->

    ProcessView = Backbone.View.extend {

        el       : '#tab-content-process'

        template : Handlebars.compile template

        render   : ->
            console.log 'process render'
            $( this.el ).html this.template this.model.attributes

    }

    processView = new ProcessView()

    return processView