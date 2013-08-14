#############################
#  View(UI logic) for design/property/rtb
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.multiinputbox', 'MC.validate', 'UI.parsley' ], ( ide_event ) ->

    RTBView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-rtb-tmpl' ).html()

        events   :

            'change .ipt-wrapper'             : 'addIp'
            'REMOVE_ROW  .multi-input'        : 'removeIp'
            'ADD_ROW     .multi-input'        : 'processParsley'
            'BEFORE_REMOVE_ROW  .multi-input' : 'beforeRemoveIp'
            'change #rt-name'                 : 'changeName'
            'click #set-main-rt'              : 'setMainRT'
            'change #checkbox_id'             : 'changePropagation'

        render     : () ->
            console.log 'property:rtb render'
            $( '.property-details' ).html this.template this.model.attributes

        processParsley: ( event ) ->
            $( event.currentTarget )
            .find( 'input' )
            .last()
            .removeClass( 'parsley-validated' )
            .next( '.parsley-error-list' )
            .remove()

        addIp : ( event ) ->

            data = event.target.parentNode.parentNode.parentNode.dataset

            children = event.target.parentNode.parentNode.parentNode.children

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_ROUTE', uid, data, children

        beforeRemoveIp : ( event ) ->
            vals = 0
            $("#property-rtb-ips input").each ()->
                v = $(this).val()
                if v
                    ++vals

            # If we only have valid item and user is trying to remove it.
            # prevent deletion
            if vals <= 1 and event.value
                return false

            null

        removeIp : ( event ) ->

            data = event.target.dataset

            children = event.target.children

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_ROUTE', uid, data, children

        changeName : ( event ) ->
            rtName = event.currentTarget.value

            # required validate
            if not MC.validate 'required', rtName
                return

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_NAME', uid, rtName

        setMainRT : () ->

            uid = $("#rt-name").data 'uid'

            this.trigger 'SET_MAIN_RT', uid

        changePropagation : ( event ) ->

            console.log event
            uid = $("#rt-name").data 'uid'
            this.trigger 'SET_PROPAGATION', uid, event.target.dataset.uid

    }

    view = new RTBView()

    return view
