#############################
#  View(UI logic) for design/property/rtb
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.multiinputbox' ], ( ide_event ) ->

    RTBView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-rtb-tmpl' ).html()

        events   :

            'change .ipt-wrapper' : 'addIp'
            'REMOVE_ROW  .multi-input' : 'removeIp'
            'change #rt-name' : 'changeName'
            'click #set-main-rt' : 'setMainRT'

        initialize : () ->

            $( document )
                .on( 'CANVAS_LINE_CREATE',          '#svg_canvas', this, this.createLine )
                .on( 'CANVAS_OBJECT_DELETE',        '#svg_canvas', this, this.deleteObject )


        render     : () ->
            console.log 'property:rtb render'
            $( '.property-details' ).html this.template this.model.attributes


        createLine : ( event, line_id ) ->

            event.data.trigger 'REFRESH_PROPERTY'

        deleteObject : ( event, option ) ->

            event.data.trigger 'REFRESH_PROPERTY'

        addIp : ( event ) ->

            data = event.target.parentNode.parentNode.parentNode.dataset

            children = event.target.parentNode.parentNode.parentNode.children

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_ROUTE', uid, data, children

        removeIp : ( event ) ->

            data = event.target.dataset

            children = event.target.children

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_ROUTE', uid, data, children

        changeName : ( event ) ->

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_NAME', uid, event.target.value

        setMainRT : () ->

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_MAIN_RT', uid


    }

    view = new RTBView()

    return view