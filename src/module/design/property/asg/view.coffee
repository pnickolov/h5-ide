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

        render     : ( attributes ) ->
            console.log 'property:asg render'
            $( '.property-details' ).html this.template this.model.attributes

        showTermPolicy : () ->
            uid = $("#autoscaling-group-property-uid").attr("data-uid")
            policies = MC.canvas_data.component[uid].resource.TerminationPolicies

            data    = []
            checked = {}

            for policy in policies
                if policy is "Default"
                    data.useDefault = true
                else
                    data.push { name : policy, checked : true }
                    checked[ policy ] = true

            for p in ["OldestInstance", "NewestInstance", "OldestLaunchConfiguration", "ClosestToNextInstanceHour"]
                if not checked[ p ]
                    data.push { name : p, checked : false }

            modal this.term_template(data), true

            self = this

            # Bind event to the popup
            $("#property-asg-term").on "change", "input", ()->
                $this = $(this)
                checked = $this.is(":checked")
                $this.closest("li").toggleClass("enabled", checked)

            $("#property-asg-term-done").on "click", ()->
                self.onEditTermPolicy()
                modal.close()

            $("#property-asg-term").on "mousedown", ".drag-handle", ()->
                $(this).trigger("mouseleave")

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

            data.push {
               name : "Default"
               checked : $("#property-asg-term-def").is(":checked")
            }

            console.log "Finish editing termination policy", data

            this.trigger 'SET_TERMINATE_POLICY', data



        updateSNSOption : () ->
            checkArray = []
            hasChecked = false
            $("#property-asg-sns input[type = checkbox]").each ()->
                checked = $(this).is(":checked")
                checkArray.push checked
                if checked
                    hasChecked = true

                null

            noSNS = true

            if noSNS and hasChecked
                $("#property-asg-sns-info").show()
            else
                $("#property-asg-sns-info").hide()

            this.trigger 'SET_SNS_OPTION', checkArray

    }

    view = new InstanceView()

    return view
