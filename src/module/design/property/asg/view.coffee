#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars', 'UI.sortable' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-asg-tmpl' ).html()

        term_template : Handlebars.compile $( '#property-asg-term-tmpl' ).html()

        policy_template : Handlebars.compile $( '#property-asg-policy-tmpl' ).html()

        events   :
            "click #property-asg-term-edit"                : "showTermPolicy"
            "click #property-asg-sns input[type=checkbox]" : "updateSNSOption"
            "change #property-asg-endpoint"                : "updateSNSOption"
            "OPTION_CHANGE #property-asg-sns-more"         : "updateSNSInput"
            "change #property-asg-elb"                     : "setHealthyCheckELBType"
            "change #property-asg-ec2"                     : "setHealthyCheckEC2Type"
            "change #property-asg-name"                    : "setASGName"
            "change #property-asg-min"                     : "setASGMin"
            "change #property-asg-max"                     : "setASGMax"
            "change #property-asg-capacity"                : "setASGDesireCapacity"
            "change #property-asg-cooldown"                : "setASGCoolDown"
            "change #property-asg-healthcheck"             : "setHealthCheckGrace"
            "click #property-asg-policy-add"               : "showScalingPolicy"



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

        showScalingPolicy : () ->
            data =
                title : "Add"

            modal this.policy_template(data), true

            self = this
            $("#property-asg-policy-done").on "click", ()->
                self.onEidtPolicy()
                modal.close()

        onEidtPolicy : () ->
            data =
                name   : $("#asg-policy-name").val()
                metric : $("#asg-policy-metric .selected").data("id")
                evaluation : $("#asg-policy-eval .selected").data("id")
                threshold  : $("#asg-policy-threshold").val()
                periods    : $("#asg-policy-periods").val()
                second     : $("#asg-policy-second").val()
                trigger    : $("#asg-policy-trigger .selected").data("id")
                adjusttype : $("#asg-policy-adjust-type .selected").data("id")
                adjustment : $("#asg-policy-adjust").val()
                statistics : $("#asg-policy-statistics .selected").data("id")
                cooldown   : $("#asg-policy-cooldown").val()
                step       : $("#asg-policy-step").val()
                notify     : $("#asg-policy-notify").is(":checked")

            console.log "Finish Editing Policy : ", data

            this.trigger 'SET_POLICY', data

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
