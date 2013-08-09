#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars', 'UI.sortable' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-asg-tmpl' ).html()

        term_template : Handlebars.compile $( '#property-asg-term-tmpl' ).html()

        events   :
            "click #property-asg-term-edit" : "showTermPolicy"
            "click #property-asg-sns input[type=checkbox]" : "updateSNSOption"
            "change #property-asg-endpoint" : "updateSNSOption"
            "OPTION_CHANGE #property-asg-sns-more" : "updateSNSInput"

        render     : ( attributes ) ->
            console.log 'property:asg render'
            $( '.property-details' ).html this.template this.model.attributes

        showTermPolicy : () ->
            uid = $("#autoscaling-group-property-uid").attr("data-uid")
            policies = MC.canvas_data.component[uid].resource.TerminationPolicies

            data = []

            for policy in policies

                data.push { name : policy, checked : true }

            for p in ["OldestInstance", "NewestInstance", "OldestLaunchConfiguration", "ClosestToNextInstanceHour", "Default"]

                existing = false

                for d in data

                    if d.name is p

                        existing = true

                if not existing

                    data.push { name : p, checked : false }
            # data = [
            #     { name : "OldestInstance", checked : if 'OldestInstance' in policies then true else false }
            #     { name : "NewestInstance", checked : true }
            #     { name : "OldestLaunchConfiguration", checked : false }
            #     { name : "ClosestToNextInstanceHour", checked : true }
            # ]
            #data.defaultChecked = true

            template = this.term_template data
            modal template, true

            self = this

            # Bind event to the popup
            $("#property-asg-term").on "change", "input", ()->
                $this = $(this)
                checked = $this.is(":checked")
                $this.closest("li").toggleClass("enabled", checked)

            $("#property-asg-term-done").on "click", ()->
                self.onEditTermPolicy()
                modal.close()

            # Init drag drop list
            $("#property-term-list").sortable({ handle : '.drag-handle' })

        onEditTermPolicy : () ->
            data = []

            $("#property-term-list .list-name").each ()->
                $this = $(this)
                data.push {
                    name    : $this.text()
                    checked : $this.closest("li").hasClass("enabled")
                }
                null

            #data.push {
            #    name : "Default"
            #    checked : $("#property-asg-term-def").is(":checked")
            #}

            console.log "Finish editing termination policy", data

            this.trigger 'SET_TERMINATE_POLICY', data



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
