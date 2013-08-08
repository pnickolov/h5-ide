#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars', 'UI.toggleicon' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-asg-tmpl' ).html()

        events   :
            "click #property-asg-sns input[type=checkbox]" : "updateSNSOption"
            "change #property-asg-endpoint" : "updateSNSOption"
            "OPTION_CHANGE #property-asg-sns-more" : "updateSNSInput"

        render     : ( attributes ) ->
            console.log 'property:asg render'
            $( '.property-details' ).html this.template this.model.attributes

        updateSNSOption : () ->
            checkArray = []
            show_more  = false
            $("#property-asg-sns input[type=checkbox]").each ()->
                checked = $(this).is(":checked")
                checkArray.push checked
                if checked
                    show_more = true

                null

            (if show_more then $.fn.show else $.fn.hide).apply $("#property-asg-sns-more")

            endpoint = $("#property-asg-endpoint").val()

            console.log "SNS selection : #{checkArray}, Endpoint Value : #{endpoint}"

            this.trigger 'SET_SNS_OPTION', checkArray, endpoint

        updateSNSInput : () ->

            $input  = $(".property-asg-ep").removeClass("https http")
            switch $("#property-asg-sns-more .selected").data("id")

                when "sqa"
                    placeholder = "e.g. Amazon ARN"

                when "email"
                    placeholder = "e.g. exmaple@acme.com"

                when "json"
                    placeholder = "e.g. example@acme.com"

                when "sms"
                    placeholder = "e.g. 1-343-21-323"

                when "http"
                    $input.addClass "http"
                    placeholder = "e.g. www.example.com"

                when "https"
                    $input.addClass "https"
                    placeholder = "e.g. www.example.com"
            $("#property-asg-endpoint").attr "placeholder", placeholder

    }

    view = new InstanceView()

    return view
