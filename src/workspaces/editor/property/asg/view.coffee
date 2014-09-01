#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         './template/stack',
         './template/policy',
         './template/term',
         'i18n!/nls/lang.js'
         'sns_dropdown'
         'UI.modalplus'
], ( PropertyView, template, policy_template, term_template, lang, snsDropdown, modalplus ) ->

    metricMap =
      "CPUUtilization"             : lang.PROP.ASG_POLICY_CPU
      "DiskReadBytes"              : lang.PROP.ASG_POLICY_DISC_READS
      "DiskReadOps"                : lang.PROP.ASG_POLICY_DISK_READ_OPERATIONS
      "DiskWriteBytes"             : lang.PROP.ASG_POLICY_DISK_WRITES
      "DiskWriteOps"               : lang.PROP.ASG_POLICY_DISK_WRITE_OPERATIONS
      "NetworkIn"                  : lang.PROP.ASG_POLICY_NETWORK_IN
      "NetworkOut"                 : lang.PROP.ASG_POLICY_NETWORK_OUT
      "StatusCheckFailed"          : lang.PROP.ASG_POLICY_STATUS_CHECK_FAILED_ANY
      "StatusCheckFailed_Instance" : lang.PROP.ASG_POLICY_STATUS_CHECK_FAILED_INSTANCE
      "StatusCheckFailed_System"   : lang.PROP.ASG_POLICY_STATUS_CHECK_FAILED_SYSTEM

    adjustMap =
      "ChangeInCapacity"        : lang.PROP.ASG_ADD_POLICY_ADJUSTMENT_CHANGE
      "ExactCapacity"           : lang.PROP.ASG_ADD_POLICY_ADJUSTMENT_EXACT
      "PercentChangeInCapacity" : lang.PROP.ASG_ADD_POLICY_ADJUSTMENT_PERCENT

    adjustdefault =
      "ChangeInCapacity"        : "eg. -1"
      "ExactCapacity"           : "eg. 5"
      "PercentChangeInCapacity" : "eg. -30"

    adjustTooltip =
      "ChangeInCapacity"        : lang.PROP.ASG_ADJUST_TOOLTIP_CHANGE
      "ExactCapacity"           : lang.PROP.ASG_ADJUST_TOOLTIP_EXACT
      "PercentChangeInCapacity" : lang.PROP.ASG_ADJUST_TOOLTIP_PERCENT

    unitMap =
        CPUUtilization : "%"
        DiskReadBytes  : "B"
        DiskWriteBytes : "B"
        NetworkIn      : "B"
        NetworkOut     : "B"

    InstanceView = PropertyView.extend {

        events   :
            "click #property-asg-term-edit"                : "showTermPolicy"
            "click #property-asg-sns input[type=checkbox]" : "setNotification"
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

        render     : () ->
            selectTopicName = @model.getNotificationTopicName()

            @snsNotiDropdown = new snsDropdown selection: selectTopicName
            @snsNotiDropdown.on 'change', @model.setNotificationTopic, @model

            @addSubView @snsNotiDropdown

            data = @model.toJSON()

            for p in data.policies
                p.unit   = unitMap[ p.alarmData.metricName ]
                p.alarmData.metricName = metricMap[ p.alarmData.metricName ]
                p.adjustmentType = adjustMap[ p.adjustmentType ]

            data.term_policy_brief = data.terminationPolicies.join(" > ")

            data.can_add_policy = data.policies.length < 25

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
                @snsNotiDropdown = new snsDropdown()
                @model.removeTopic()
                @$( '.sns-group' ).hide()

        processPolicyTopic: ( display, policyObject, needInit ) ->
            selection = if policyObject then policyObject.getTopicName() else null
            dropdown = new snsDropdown selection: selection
            @addSubView dropdown

            if display
                $( '.policy-sns-placeholder' ).html dropdown.render(needInit).el
                $( '.sns-policy-field' ).show()
            else
                dropdown = new snsDropdown()
                $( '.sns-policy-field' ).hide()


        setASGCoolDown : ( event ) ->
            $target = $ event.target

            $target.parsley 'custom', ( val ) ->
                if _.isNumber( +val ) and +val > 86400
                    return lang.PARSLEY.MAX_VALUE_86400
                null

            if $target.parsley 'validate'
                @model.setASGCoolDown $target.val()

        setASGName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "ASG" )
                @model.setName name
                @setTitle name

        setSizeGroup: ( event ) ->
            that        = @
            $min        = @$el.find '#property-asg-min'
            $max        = @$el.find '#property-asg-max'
            $capacity   = @$el.find '#property-asg-capacity'

            $min.parsley 'custom', ( val ) ->
                if + val > + $max.val()
                    return lang.PARSLEY.MINIMUM_SIZE_MUST_BE_LESSTHAN_MAXIMUM_SIZE
                that.constantCheck val

            $max.parsley 'custom', ( val ) ->
                if + val < + $min.val()
                    return lang.PARSLEY.MAXIMUM_SIZE_MUST_BE_MORETHAN_MINIMUM_SIZE
                that.constantCheck val

            $capacity.parsley 'custom', ( val ) ->
                if + val < + $min.val() or + val > + $max.val()
                    return lang.PARSLEY.DESIRED_CAPACITY_IN_ALLOW_SCOPE
                that.constantCheck val

            if $( event.currentTarget ).parsley 'validateForm'
                @model.setASGMin $min.val()
                @model.setASGMax $max.val()
                @model.setASGDesireCapacity $capacity.val()

        constantCheck: (val) ->
            val = +val

            if val < 1
                return sprintf lang.PARSLEY.VALUE_MUST_BE_GREATERTHAN_VAR, 1

            if val > 65534
                return sprintf lang.PARSLEY.VALUE_MUST_BE_LESSTHAN_VAR, 65534

            null



        setHealthCheckGrace : ( event ) ->
            $target = $ event.currentTarget

            $target.parsley 'custom', ( val ) ->
                val = + val
                if val < 0 or val > 86400
                    return sprintf lang.PARSLEY.VALUE_MUST_IN_ALLOW_SCOPE, 0, 86400

            if $target.parsley 'validate'
                @model.setHealthCheckGrace $target.val()

        showTermPolicy : () ->
            data    = []
            checked = {}

            for policy in @model.get("terminationPolicies")
                if policy is "Default"
                    data.useDefault = true
                else
                    data.push { name : policy, checked : true }
                    checked[ policy ] = true

            for p in [lang.PROP.ASG_TERMINATION_POLICY_OLDEST, lang.PROP.ASG_TERMINATION_POLICY_NEWEST, lang.PROP.ASG_TERMINATION_POLICY_OLDEST_LAUNCH, lang.PROP.ASG_TERMINATION_POLICY_CLOSEST]
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

            uid = $( event.currentTarget ).closest("li").data("uid")

            data = @model.getPolicy(uid)

            data.uid   = uid
            data.title = lang.PROP.ASG_ADD_POLICY_TITLE_EDIT

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
                title           : lang.PROP.ASG_ADD_POLICY_TITLE_ADD + ' ' + lang.PROP.ASG_ADD_POLICY_TITLE_CONTENT
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
                    title   : lang.PROP.ASG_ADD_POLICY_TITLE_ADD
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

            #modal policy_template(data), true
            @openPolicyModal data


            self = this

            $("#asg-policy-name").parsley 'custom', ( name ) ->
                uid  = $("#property-asg-policy").data("uid")

                if self.model.isDupPolicyName uid, name
                    return lang.PARSLEY.DUPLICATED_POLICY_NAME


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
                else if val > 86400
                    val = 86400

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


            @processPolicyTopic $( '#asg-policy-notify' ).prop( 'checked' ), policyObject, false
            $("#asg-policy-notify").off("click").on "click", ( evt )->
                evt.stopPropagation()
                self.processPolicyTopic evt.target.checked, policyObject, true


                null

            $("#asg-policy-metric").on "OPTION_CHANGE", ()->
                $("#asg-policy-unit").html( unitMap[$(this).find(".selected").data("id")] || "" )
                $( '#asg-policy-threshold' ).val ''

            null

        onPolicyDone : () ->

            data =
                uid              : $("#property-asg-policy").data("uid")
                name             : $("#asg-policy-name").val()
                cooldown         : $("#asg-policy-cooldown").val()
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
            $("#property-asg-elb-warn").toggle( $("#property-asg-elb").is(":checked") )

        setHealthyCheckEC2Type :( event ) ->
            @model.setHealthCheckType 'EC2'
            $("#property-asg-elb-warn").toggle( $("#property-asg-elb").is(":checked") )


    }

    new InstanceView()
