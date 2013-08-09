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
            "change #property-asg-elb" : "setHealthyCheckELBType"
            "change #property-asg-ec2" : "setHealthyCheckEC2Type"
            "change #property-asg-name" : "setASGName"
            "change #property-asg-min" : "setASGMin"
            "change #property-asg-max" : "setASGMax"
            "change #property-asg-capacity" : "setASGDesireCapacity"
            "change #property-asg-cooldown" : "setASGCoolDown"
            "change #property-asg-healthcheck" : "setHealthCheckGrace"


        render     : ( attributes ) ->
            console.log 'property:asg render'
            $( '.property-details' ).html this.template this.model.attributes

        setASGCoolDown : ( event ) ->

            this.trigger 'SET_COOL_DOWN', event.target.value

        setASGName : ( event ) ->

            this.trigger 'SET_ASG_NAME', event.target.value

        setASGMin : ( event ) ->

            this.trigger 'SET_ASG_MIN', event.target.value

        setASGMax : ( event ) ->

            this.trigger 'SET_ASG_MAX', event.target.value

        setASGDesireCapacity : ( event ) ->

            this.trigger 'SET_DESIRE_CAPACITY', event.target.value

        setHealthCheckGrace : ( event ) ->

            this.trigger 'SET_HEALTH_CHECK_GRACE', event.target.value

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

            #data.push {
            #    name : "Default"
            #    checked : $("#property-asg-term-def").is(":checked")
            #}

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

        setHealthyCheckELBType :( event ) ->

            this.trigger 'SET_HEALTH_TYPE', 'ELB'

        setHealthyCheckEC2Type :( event ) ->

            this.trigger 'SET_HEALTH_TYPE', 'EC2'

    }

    view = new InstanceView()

    return view
