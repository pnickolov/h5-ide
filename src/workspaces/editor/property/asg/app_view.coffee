#############################
#  View(UI logic) for design/property/instance(app)
#############################

define [ '../base/view',
         './template/app',
         './template/policy',
         './template/term',
         'i18n!nls/lang.js'
         'sns_dropdown'
         'UI.modalplus'
], ( PropertyView, template, policy_template, term_template, lang, snsDropdown, modalplus )->

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
        "ExactCapacity"           : "Change the current capacity of your Auto Scaling group to the exact value specified."
        "PercentChangeInCapacity" : "Increase or decrease the desired capacity by a percentage of the desired capacity. A positive value adds to the current capacity and a negative value removes from the current capacity"

    unitMap =
        CPUUtilization : "%"
        DiskReadBytes  : "B"
        DiskWriteBytes : "B"
        NetworkIn      : "B"
        NetworkOut     : "B"


    ASGAppEditView = PropertyView.extend {
        events   :
            "change #property-asg-min"      : "setSizeGroup"
            "change #property-asg-max"      : "setSizeGroup"
            "change #property-asg-capacity" : "setSizeGroup"

            "click #property-asg-term-edit"                : "showTermPolicy"
            "click #property-asg-sns input[type=checkbox]" : "setNotification"
            "change #property-asg-elb"                     : "setHealthyCheckELBType"
            "change #property-asg-ec2"                     : "setHealthyCheckEC2Type"
            "change #property-asg-cooldown"                : "setASGCoolDown"
            "change #property-asg-healthcheck"             : "setHealthCheckGrace"
            "click #property-asg-policy-add"               : "addScalingPolicy"
            "click #property-asg-policies .icon-edit"      : "editScalingPolicy"
            "click #property-asg-policies .icon-del"       : "delScalingPolicy"

        setASGCoolDown : ( event ) ->
            $target = $ event.target

            $target.parsley 'custom', ( val ) ->
                if _.isNumber( +val ) and +val > 86400
                    return lang.ide.PARSLEY_MAX_VALUE_86400
                null

            if $target.parsley 'validate'
                @model.setASGCoolDown $target.val()


        setHealthCheckGrace : ( event ) ->
            @model.setHealthCheckGrace event.target.value

        showTermPolicy : () ->
            data    = []
            checked = {}

            for policy in @model.get("terminationPolicies")
                if policy is "Default"
                    data.useDefault = true
                else
                    data.push { name : policy, checked : true }
                    checked[ policy ] = true

            for p in [lang.ide.PROP_ASG_TERMINATION_POLICY_OLDEST, lang.ide.PROP_ASG_TERMINATION_POLICY_NEWEST, lang.ide.PROP_ASG_TERMINATION_POLICY_OLDEST_LAUNCH, lang.ide.PROP_ASG_TERMINATION_POLICY_CLOSEST]
                if not checked[ p ]
                    data.push { name : p, checked : false }

            modal term_template(data), true

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
                if $this.closest("li").hasClass("enabled")
                    data.push $this.text()
                null

            if $("#property-asg-term-def").is(":checked")
                data.push "Default"

            $(".termination-policy-brief").text( data.join(" > ") )

            @model.setTerminatePolicy data

        delScalingPolicy  : ( event ) ->
            $li = $( event.currentTarget ).closest("li")
            uid = $li.data("uid")
            $li.remove()

            $("#property-asg-policy-add").removeClass("tooltip disabled")

            @model.delPolicy uid

        updateScalingPolicy : ( data ) ->
            # Add or update the policy
            metric     = metricMap[ data.alarmData.metricName ]
            adjusttype = adjustMap[ data.adjustmentType ]
            unit       = unitMap[ data.alarmData.metricName ] || ""

            if not data.uid
                console.error "Cannot find scaling policy uid"
                return

            $policies = $("#property-asg-policies")
            $li = $policies.children("[data-uid='#{data.uid}']")
            if $li.length is 0
                # Create a scaling policy
                $li = $policies.children(".hide").clone().attr("data-uid", data.uid).removeClass("hide").appendTo $policies

                # Check if we have 25 policy already.
                # There's a template item inside the ul, so the length shoud be 26
                $("#property-asg-policy-add").toggleClass("tooltip disabled", $("#property-asg-policies").children().length >= 26)


            $li.find(".name").html data.name
            $li.find(".asg-p-metric").html  metric
            $li.find(".asg-p-eval").html    data.alarmData.comparisonOperator + " " + data.alarmData.threshold + unit
            $li.find(".asg-p-periods").html data.alarmData.evaluationPeriods + "x" + Math.round( data.alarmData.period / 60 ) + "m"
            $li.find(".asg-p-trigger").html( data.state ).attr("class", "asg-p-trigger asg-p-tag asg-p-trigger-" + data.state )
            $li.find(".asg-p-adjust").html  data.adjustment + " " + data.adjustmentType

        editScalingPolicy : ( event ) ->
            $itemLi = $( event.currentTarget ).closest("li")
            uid = $itemLi.data('uid')
            isOld = $itemLi.data('old')

            data = @model.getPolicy(uid)

            data.uid   = uid
            data.title = lang.ide.PROP_ASG_ADD_POLICY_TITLE_EDIT
            data.isOld = isOld

            @showScalingPolicy( data )

            selectMap =
                metric        : data.alarmData.metricName
                eval          : data.alarmData.comparisonOperator
                trigger       : data.state
                "adjust-type" : data.adjustmentType
                statistics    : data.alarmData.statistic

            for key, value of selectMap
                $selectbox = $("#asg-policy-#{key}")
                $selected  = null

                for item in $selectbox.find(".item")
                    $item = $(item)
                    if $item.data("id") is value
                        $selected = $item
                        break

                if $selected
                    $selectbox.find(".selected").removeClass "selected"
                    $selectbox.find(".selection").html $selected.addClass("selected").html()

            $(".pecentcapcity").toggle( $("#asg-policy-adjust-type").find(".selected").data("id") == "PercentChangeInCapacity" )

        addScalingPolicy : ( event ) ->
            if $( event.currentTarget ).hasClass "disabled"
                return false

            @showScalingPolicy()
            false

        openPolicyModal: ( data ) ->
            options =
                template        : policy_template data
                title           : lang.ide.PROP_ASG_ADD_POLICY_TITLE_ADD
                width           : '480px'
                compact         : true
                confirm         :
                    text: 'Done'

            modalPlus = new modalplus options
            that = @
            modalPlus.on 'confirm', () ->

                result = $("#asg-termination-policy").parsley("validate")
                if result is false
                    return false
                that.onPolicyDone()
                modalPlus.close()

            ,@


        showScalingPolicy : ( data ) ->
            if !data
                data =
                    title   : lang.ide.PROP_ASG_ADD_POLICY_TITLE_ADD
                    name    : @model.defaultScalingPolicyName()
                    minAdjustStep : 1
                    alarmData : {
                        evaluationPeriods : 2
                        period : 5
                    }

            if data.uid
                policyObject = Design.instance().component data.uid

            if data.alarmData and data.alarmData.metricName
                data.unit = unitMap[ data.alarmData.metricName ]
            else
                data.unit = '%'

            data.detail_monitor = this.model.attributes.detail_monitor

            #modal policy_template(data), true
            @openPolicyModal data

            self = this

            $("#asg-policy-name").parsley 'custom', ( name ) ->
                uid  = $("#property-asg-policy").data("uid")

                if self.model.isDupPolicyName uid, name
                    return lang.ide.PARSLEY_DUPLICATED_POLICY_NAME


            $("#asg-policy-periods").on "change", () ->
                val = parseInt $(this).val(), 10
                if not val or val < 1
                    $(this).val( "1" )
                if val > 86400
                    $(@).val 86400

            $("#asg-policy-second").on "change", () ->
                val = parseInt $(this).val(), 10
                if not val or val < 1
                    $(this).val( "1" )

                if val > 1440
                    $(@).val 1440

            $("#asg-policy-adjust-type").on "OPTION_CHANGE", ()->
                type = $(this).find(".selected").data("id")
                if type is 'PercentChangeInCapacity'
                    $(".pecentcapcity").toggle true
                    $('#asg-policy-step').val 1 if $('#asg-policy-step').val() is ''
                else
                    $(".pecentcapcity").toggle false

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

                if val < -65534
                    $(@).val -65534
                else if val > 65534
                    $(@).val 65534

                    # More than 100% is legal.
                    # else if val > 100
                    #     $(this).val( "100" )

                $("#").data("tooltip", adjustTooltip[ type ] ).trigger("change")


            $("#asg-policy-cooldown").on "change", ()->
                $this = $("#asg-policy-cooldown")

                val   = parseInt $this.val(), 10
                if isNaN( val )
                    return

                if val < 0
                    val = 0
                else if val > 1440
                    val = 1440

                $this.val( val )


            $("#asg-policy-step").on "change", ()->
                $this = $("#asg-policy-step")

                val   = parseInt $this.val(), 10
                if isNaN( val )
                    return

                if val < 0
                    val = 0
                else if val > 65534
                    val = 65534

                $this.val( val )

            $("#asg-policy-threshold").on "change", ()->
                metric = $("#asg-policy-metric .selected").data("id")
                val    = parseInt $(this).val(), 10
                if metric is "CPUUtilization"
                    if isNaN( val ) or val < 1
                        $(this).val( "1" )
                    else if val > 100
                        $(this).val( "100" )

            selection = if policyObject then policyObject.getTopicName() else null
            snsPolicyDropdown = new snsDropdown selection: selection

            @processPolicyTopic $( '#asg-policy-notify' ).prop( 'checked' ), snsPolicyDropdown, false
            $("#asg-policy-notify").off("click").on "click", ( evt )->
                evt.stopPropagation()
                self.processPolicyTopic evt.target.checked, snsPolicyDropdown, true


                null

            $("#asg-policy-metric").on "OPTION_CHANGE", ()->
                $("#asg-policy-unit").html( unitMap[$(this).find(".selected").data("id")] || "" )
                $( '#asg-policy-threshold' ).val ''

            null

        onPolicyDone : () ->

            data =
                uid              : $("#property-asg-policy").data("uid")
                name             : $("#asg-policy-name").val()
                cooldown         : $("#asg-policy-cooldown").val() * 60
                minAdjustStep    : ""
                adjustment       : $("#asg-policy-adjust").val()
                adjustmentType   : $("#asg-policy-adjust-type .selected").data("id")
                state            : $("#asg-policy-trigger .selected").data("id")
                sendNotification : $("#asg-policy-notify").is(":checked")

                alarmData : {
                    metricName         : $("#asg-policy-metric .selected").data("id")
                    comparisonOperator : $("#asg-policy-eval .selected").data("id")
                    period             : $("#asg-policy-second").val() * 60
                    evaluationPeriods  : $("#asg-policy-periods").val()
                    statistic          : $("#asg-policy-statistics .selected").data("id")
                    threshold          : $("#asg-policy-threshold").val()
                }


            if data.adjustmentType is 'PercentChangeInCapacity'
                data.minAdjustStep = $("#asg-policy-step").val()

            if data.sendNotification
                selectedTopicData = $('.policy-sns-placeholder .selected').data()
                if selectedTopicData and selectedTopicData.id and selectedTopicData.name
                    data.topic = appId: selectedTopicData.id, name: selectedTopicData.name

            @model.setPolicy data
            @updateScalingPolicy data
            null

        setNotification : () ->
            checkMap = {}
            hasChecked = false
            $("#property-asg-sns input[type = checkbox]").each ()->
                checked = $(this).is(":checked")
                checkMap[ $(this).attr("data-key") ] = checked

                if checked then hasChecked = true

                null

            if hasChecked
                $("#property-asg-sns-info").show()
            else
                $("#property-asg-sns-info").hide()

            originHasNoti = @wheatherHasNoti()
            @model.setNotification checkMap
            @processNotiTopic originHasNoti

        setHealthyCheckELBType :( event ) ->
            @model.setHealthCheckType 'ELB'
            $("#property-asg-elb-warn").toggle($("#property-asg-elb").is(":checked") )

        setHealthyCheckEC2Type :( event ) ->
            @model.setHealthCheckType 'EC2'
            $("#property-asg-elb-warn").toggle($("#property-asg-elb").is(":checked") )

        render : () ->
            selectTopicName = @model.getNotificationTopicName()
            @snsNotiDropdown = new snsDropdown selection: selectTopicName
            @snsNotiDropdown.on 'change', @model.setNotificationTopic, @model

            data = @model.toJSON()
            if data.isEditable
                for p in data.policies
                    p.alarmData.metricName = metricMap[ p.alarmData.metricName ]
                    p.unit   = unitMap[ p.alarmData.metricName ]
                    p.adjustmentType = adjustMap[ p.adjustmentType ]
                    p.isNew = not p.appId

                data.term_policy_brief = data.terminationPolicies.join(" > ")
                data.can_add_policy = data.policies.length < 25

            console.debug data
            @$el.html template data

            @processNotiTopic null, true

            data.name

        wheatherHasNoti: ->
            n = @model.notiObject?.toJSON()
            n and (n.instanceLaunch or n.instanceLaunchError or n.instanceTerminate or n.instanceTerminateError or n.test)

        processNotiTopic: ( originHasNoti, render ) ->
            hasNoti = @wheatherHasNoti()
            if render and hasNoti
                @$( '#sns-placeholder' ).html @snsNotiDropdown.render().el
                @$( '.sns-group' ).show()
            else if not originHasNoti and hasNoti
                @$( '#sns-placeholder' ).html @snsNotiDropdown.render( true ).el
                @$( '.sns-group' ).show()
            else if originHasNoti and not hasNoti
                @model.removeTopic()
                @$( '.sns-group' ).hide()

        processPolicyTopic: ( display, dropdown, needInit ) ->
            if display
                $( '.policy-sns-placeholder' ).html dropdown.render(needInit).el
                $( '.sns-policy-field' ).show()
            else
                $( '.sns-policy-field' ).hide()


        setSizeGroup: ( event ) ->
            $min        = @$el.find '#property-asg-min'
            $max        = @$el.find '#property-asg-max'
            $capacity   = @$el.find '#property-asg-capacity'

            $min.parsley 'custom', ( val ) ->
                if + val < 1
                    return lang.ide.PARSLEY_ASG_SIZE_MUST_BE_EQUAL_OR_GREATER_THAN_1
                if + val > + $max.val()
                    return lang.ide.PARSLEY_MINIMUM_SIZE_MUST_BE_LESSTHAN_MAXIMUM_SIZE

            $max.parsley 'custom', ( val ) ->
                if + val < 1
                    return lang.ide.PARSLEY_ASG_SIZE_MUST_BE_EQUAL_OR_GREATER_THAN_1
                if + val < + $min.val()
                    return lang.ide.PARSLEY_MINIMUM_SIZE_MUST_BE_LESSTHAN_MAXIMUM_SIZE

            $capacity.parsley 'custom', ( val ) ->
                if + val < 1
                    return lang.ide.PARSLEY_DESIRED_CAPACITY_EQUAL_OR_GREATER_1
                if + val < + $min.val() or + val > + $max.val()
                    return lang.ide.PARSLEY_DESIRED_CAPACITY_IN_ALLOW_SCOPE

            if $( event.currentTarget ).parsley 'validateForm'
                @model.setASGMin $min.val()
                @model.setASGMax $max.val()
                @model.setASGDesireCapacity $capacity.val()
    }

    new ASGAppEditView()
