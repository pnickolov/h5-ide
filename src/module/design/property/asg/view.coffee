#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'UI.zeroclipboard', 'backbone', 'jquery', 'handlebars', 'UI.sortable' ], ( ide_event, MC, zeroclipboard ) ->

    metricMap =
        "CPUUtilization"             : "CPU Utilization"
        "DiskReadBytes"              : "Disk Reads"
        "DiskReadOps"                : "Disk Read Operations"
        "DiskWriteBytes"             : "Disk Writes"
        "DiskWriteOps"               : "Disk Write Operations"
        "NetworkIn"                  : "Network In"
        "NetworkOut"                 : "Network Out"
        "StatusCheckFailed"          : "Status Check Failed (Any)"
        "StatusCheckFailed_Instance" : "Status Check Failed (Instance)"
        "StatusCheckFailed_System"   : "Status Check Failed (System)"

    adjustMap =
        "ChangeInCapacity"        : "Change in Capacity"
        "ExactCapacity"           : "Exact Capacity"
        "PercentChangeInCapacity" : "Percent Change in Capacity"

    adjustdefault =
        "ChangeInCapacity"        : "eg. -1"
        "ExactCapacity"           : "eg. 5"
        "PercentChangeInCapacity" : "eg. -30"

    adjustTooltip =
        "ChangeInCapacity"        : "Increase or decrease existing capacity by integer you input here. A positive value adds to the current capacity and a negative value removes from the current capacity."
        "ExactCapacity"           : "Change the current capacity of your Auto Scaling group to the exact value speciﬁed."
        "PercentChangeInCapacity" : "Increase or decrease the desired capacity by a percentage of the desired capacity. A positive value adds to the current capacity and a negative value removes from the current capacity"

    unitMap =
        CPUUtilization : "%"
        DiskReadBytes  : "B"
        DiskWriteBytes : "B"
        NetworkIn      : "B"
        NetworkOut     : "B"

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template        : Handlebars.compile $( '#property-asg-tmpl' ).html()
        term_template   : Handlebars.compile $( '#property-asg-term-tmpl' ).html()
        policy_template : Handlebars.compile $( '#property-asg-policy-tmpl' ).html()
        app_template    : Handlebars.compile $( '#property-asg-app-tmpl' ).html()

        events   :
            "click #property-asg-term-edit"                : "showTermPolicy"
            "click #property-asg-sns input[type=checkbox]" : "updateSNSOption"
            "change #property-asg-endpoint"                : "updateSNSOption"
            "OPTION_CHANGE #property-asg-sns-more"         : "updateSNSInput"
            "change #property-asg-elb"                     : "setHealthyCheckELBType"
            "change #property-asg-ec2"                     : "setHealthyCheckEC2Type"
            "change #property-asg-name"                    : "setASGName"
            "change #property-asg-min"                     : "setSizeGroup"
            "change #property-asg-max"                     : "setSizeGroup"
            "change #property-asg-capacity"                : "setSizeGroup"
            "change #property-asg-cooldown"                : "setASGCoolDown"
            "change #property-asg-healthcheck"             : "setHealthCheckGrace"
            "click #property-asg-policy-add"               : "addScalingPolicy"
            "click #property-asg-policies .icon-edit"      : "editScalingPolicy"
            "click #property-asg-policies .icon-del"       : "delScalingPolicy"


        render     : ( isApp ) ->
            console.log 'property:asg render'
            data = this.model.attributes

            if data.asg

                data = $.extend true, {}, this.model.attributes

                policies = []
                for uid, policy of data.policies
                    policy.metric     = metricMap[ policy.metric ]
                    policy.adjusttype = adjustMap[ policy.adjusttype ]
                    policy.unit       = unitMap[ policy.metric ]
                    policies.push policy

                data.term_policy_brief = data.asg.TerminationPolicies.join(" > ")

            template = if isApp then this.app_template else this.template

            $( '.property-details' ).html template data

            if isApp
                zeroclipboard.copy $( "#property_app_asg .icon-copy" )
            null

        setASGCoolDown : ( event ) ->

            this.trigger 'SET_COOL_DOWN', event.target.value

        setASGName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()
            id = @model.get 'uid'

            MC.validate.preventDupname target, id, name, 'ASG'

            if target.parsley 'validate'
                this.trigger 'SET_ASG_NAME', event.target.value

        setSizeGroup: ( event ) ->
            $min        = @$el.find '#property-asg-min'
            $max        = @$el.find '#property-asg-max'
            $capacity   = @$el.find '#property-asg-capacity'

            $min.parsley 'custom', ( val ) =>
                if + val < 1
                    return 'ASG size must be equal or greater than 1'
                if + val >= + $max.val()
                    return 'Minimum Size must be <= Maximum Size.'

            $max.parsley 'custom', ( val ) =>
                if + val < 1
                    return 'ASG size must be equal or greater than 1'
                if + val <= + $min.val()
                    return 'Minimum Size must be <= Maximum Size'

            $capacity.parsley 'custom', ( val ) ->
                if + val < 1
                    return 'Desired Capacity must be equal or greater than 1'
                if + val < + $min.val() or + val > + $max.val()
                    return 'Desired Capacity must be >= Minimal Size and <= Maximum Size'

            if $( event.currentTarget ).parsley 'validateForm'
                @trigger 'SET_ASG_MIN', $min.val()
                @trigger 'SET_ASG_MAX', $max.val()
                @trigger 'SET_DESIRE_CAPACITY', $capacity.val()

        setHealthCheckGrace : ( event ) ->

            this.trigger 'SET_HEALTH_CHECK_GRACE', event.target.value

        showTermPolicy : () ->
            policies = this.model.attributes.asg.TerminationPolicies

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
            $("#property-asg-term").on "click", "input", ()->
                $checked = $("#property-asg-term").find("input:checked")
                if $checked.length is 0
                    return false

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

        delScalingPolicy  : ( event ) ->
            $li = $( event.currentTarget ).closest("li")
            uid = $li.data("uid")
            $li.remove()

            $("#property-asg-policy-add").removeClass("tooltip disabled")

            this.trigger 'DELETE_POLICY', uid

        updateScalingPolicy : ( data ) ->
            # Add or update the policy
            metric     = metricMap[ data.metric ]
            adjusttype = adjustMap[ data.adjusttype ]
            unit       = unitMap[ data.metric ] || ""

            if not data.uid
                throw new Error "Cannot find scaling policy uid"

            $policies = $("#property-asg-policies")
            $li = $policies.children("[data-uid='#{data.uid}']")
            if $li.length is 0
                # Create a scaling policy
                $li = $policies.children(".hide").clone().attr("data-uid", data.uid).removeClass("hide").appendTo $policies

                # Check if we have 25 policy already.
                # There's a template item inside the ul, so the length shoud be 26
                if $("#property-asg-policies").children().length is 26
                    $("#property-asg-policy-add").addClass("tooltip disabled")


            $li.find(".name").html data.name
            $li.find(".asg-p-metric").html  metric
            $li.find(".asg-p-eval").html    data.evaluation + " " + data.threshold + unit
            $li.find(".asg-p-periods").html data.periods + "x" + data.second + "s"
            $li.find(".asg-p-trigger").html( data.trigger ).attr("class", "asg-p-trigger asg-p-tag asg-p-trigger-" + data.trigger )
            $li.find(".asg-p-adjust").html  data.adjustment + " " + data.adjusttype

        editScalingPolicy : ( event ) ->

            uid = $( event.currentTarget ).closest("li").data("uid")

            data = $.extend true, {}, this.model.attributes.policies[ uid ]

            data.uid            = uid
            data.title          = "Edit"
            data.detail_monitor = this.model.attributes.detail_monitor

            this.showScalingPolicy( data )

            selectMap =
                metric     : "metric"
                evaluation : "eval"
                trigger    : "trigger"
                adjusttype : "adjust-type"
                statistics : "statistics"

            for key, value of selectMap
                $selectbox = $("#asg-policy-#{value}")
                $selected  = null

                for item in $selectbox.find(".item")
                    $item = $(item)
                    if $item.data("id") is data[key]
                        $selected = $item
                        break

                if $selected
                    $selectbox.find(".selected").removeClass "selected"
                    $selectbox.find(".selection").html $selected.addClass("selected").html()

            $("#asg-policy-step-wrapper").toggle( $("#asg-policy-adjust-type").find(".selected").data("id") == "PercentChangeInCapacity" )

        addScalingPolicy : ( event ) ->
            if $( event.currentTarget ).hasClass "disabled"
                return false

            this.showScalingPolicy()
            false


        showScalingPolicy : ( data ) ->
            if !data
                data =
                    title   : "Add"
                    second  : 300
                    periods : 2
                    step    : 1
                    name    : this.model.defaultScalingPolicyName()

            data.noSNS = not this.model.attributes.has_sns_topic

            modal this.policy_template(data), true

            self = this
            $("#property-asg-policy-done").on "click", ()->
                result = self.onPolicyDone()
                if result is false
                    return false
                modal.close()

            $("#asg-policy-name").parsley 'custom', () ->
                name = $("#asg-policy-name").val()
                uid  = $("#property-asg-policy").data("uid")

                if self.model.isDupPolicyName uid, name
                    return "Duplicated policy name in this autoscaling group"


            $("#asg-policy-periods, #asg-policy-second").on "change", ()->
                val = parseInt $(this).val(), 10
                if not val or val < 1
                    $(this).val( "1" ).parsley("validate")

            $("#asg-policy-adjust-type").on "OPTION_CHANGE", ()->
                type = $(this).find(".selected").data("id")
                $(".pecentcapcity").toggle( type == "PercentChangeInCapacity" )
                $("#asg-policy-adjust").attr("placeholder", adjustdefault[type] ).data("tooltip", adjustTooltip[ type ] ).trigger("change")

            $("#asg-policy-adjust").on "change", ()->
                type = $("#asg-policy-adjust-type").find(".selected").data("id")
                val  = parseInt $(this).val(), 10

                if type is "ExactCapacity"
                    if not val or val < 1
                        $(this).val( "1" )
                else if type is "PercentChangeInCapacity"
                    if not val
                        $(this).val( "0" )
                    else if val < -100
                        $(this).val( "-100" )
                    else if val > 100
                        $(this).val( "100" )

                $("#").data("tooltip", adjustTooltip[ type ] ).trigger("change")


            $("#asg-policy-notify").on "click", ( evt )->
                $("#asg-policy-no-sns").toggle( $("#asg-policy-notify").is(":checked") )
                evt.stopPropagation()
                null

            $("#asg-policy-metric").on "OPTION_CHANGE", ()->
                $("#asg-policy-unit").html( unitMap[$(this).find(".selected").data("id")] || "" )

        onPolicyDone : () ->

            result = $("#asg-termination-policy").parsley("validate")
            if not result
                return false

            data =
                name       : $("#asg-policy-name").val()
                metric     : $("#asg-policy-metric .selected").data("id")
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
                uid        : $("#property-asg-policy").data("uid")

            console.log "Finish Editing Policy : ", data

            this.trigger 'SET_POLICY', data

            this.updateScalingPolicy data
            null

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
