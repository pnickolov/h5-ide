#############################
#  View(UI logic) for dialog
#############################

define [ 'event',
         'text!./module/process/template.html',
         'backbone', 'jquery', 'handlebars'
], ( ide_event, template ) ->

    ProcessView = Backbone.View.extend {

        el       : '#tab-content-process'

        template : Handlebars.compile template

        events:
            'click .btn-close-process'      : 'closeProcess'

        render   : ->
            console.log 'process render'
            $( this.el ).html this.template this.model.attributes

        closeProcess : ->
            console.log 'closeProcess'

            ide_event.trigger ide_event.CLOSE_TAB, null, MC.data.current_tab_id

    }

    processView = new ProcessView()

    return processView