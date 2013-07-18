#############################
#  View(UI logic) for design/property/stack
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.notification' ], ( ide_event ) ->

    StackView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-stack-tmpl' ).html()

        events   :
            'change #stack-name' : 'stackNameChanged'

        render     : () ->
            console.log 'property:stack render'
            $( '.property-details' ).html this.template this.model.attributes

        stackNameChanged : () ->
            me = this
            
            name = $( '#stack-name' ).val()
            #check stack name
            if name.slice(0,1) == '-'
                notification 'error', 'Stack name cannot start with dash'
            else not name

            else if name in MC.data.stack_list[MC.canvas_data.region]
                notification 'error', 'Stack name \"' + name + '\" is already in user. Please use another one.'


    }

    view = new StackView()

    return view