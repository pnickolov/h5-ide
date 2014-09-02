#############################
#  View(UI logic) for design/property/sg
#############################

define [ '../base/view',
         './template/stack',
         './template/app',
         'constant',
         'i18n!/nls/lang.js'
], ( PropertyView, template, app_template, constant, lang ) ->

    SgView = PropertyView.extend {

        events   :
            #for sg rule
            'click #sg-add-rule-icon' : 'showCreateRuleModal'
            'click .sg-rule-delete'   : 'removeRulefromList'

            #for sg detail
            'change #securitygroup-name'           : 'setSGName'
            'change #securitygroup-description'    : 'setSGDescription'
            'OPTION_CHANGE #sg-rule-filter-select' : 'sortSgRule'


        render : () ->
            tpl = if @model.isReadOnly then app_template else template

            @$el.html tpl @model.toJSON()
            @refreshSgruleList()

            @setTitle @model.get("name")
            @prependTitle '<span class="sg-color" style="background-color:' + @model.get("color") + '" ></span>'

            @forceShow()

            # The secondary property will slide out.
            # We need to focus the input after it finishes transition
            setTimeout () ->
                $('#securitygroup-name').focus()
            , 200

            @model.get "name"

        refreshSgruleList : ()->
            rules = @model.get 'rules'
            rules.deletable = @model.get 'ruleEditable'
            $('#sg-rule-list').html MC.template.sgRuleList( rules )

        showCreateRuleModal : (event) ->
            # get sg list
            modal MC.template.modalSGRule @model.createSGRuleData()

            # Bind events
            $("#sg-modal-direction").on("click", "input", @radioSgModalChange )
            $("#modal-protocol-select").on("OPTION_CHANGE", @sgModalSelectboxChange )
            $("#protocol-icmp-main-select").on("OPTION_CHANGE", @icmpMainSelect )
            $("#sg-protocol-select-result").on("OPTION_CHANGE", ".protocol-icmp-sub-select", @icmpSubSelect )
            $("#sg-modal-save").on("click", _.bind( @saveSgModal, @ ))
            $("#sg-add-model-source-select").on("OPTION_CHANGE", @modalRuleSourceSelected)
            return false

        radioSgModalChange : (event) ->
            if $('#sg-modal-direction input:checked').val() is "inbound"
                $('#rule-modal-ip-range').text "Source"
            else
                $('#rule-modal-ip-range').text "Destination"

        sgModalSelectboxChange : (event, id) ->
            $('#sg-protocol-select-result').find('.show').removeClass('show')
            $('.sg-protocol-option-input').removeClass("show")
            $('#sg-protocol-' + id).addClass('show')
            $('.protocol-icmp-sub-select').removeClass('shown')
            $('#modal-protocol-select').data('protocal-type', id)
            null

        icmpMainSelect : ( event, id ) ->
            $("#protocol-icmp-main-select").data('protocal-main', id)
            if id is "3" || id is "5" || id is "11" || id is "12"
                $('.protocol-icmp-sub-select').removeClass('shown')
                $( '#protocol-icmp-sub-select-' + id).addClass('shown')
            else
                $('.protocol-icmp-sub-select').removeClass('shown')

        icmpSubSelect : ( event, id ) ->
            $("#protocol-icmp-main-select").data('protocal-sub', id)

        modalRuleSourceSelected : (event) ->
            value = $.trim($(event.target).find('.selected').attr('data-id'))
            isCustom = value is 'custom'
            $('#securitygroup-modal-description').toggle( isCustom )
            $('#sg-add-model-source-select .selection').width( if isCustom then 69 else 322 )
            null

        setSGName : ( event ) ->
            target = $ event.currentTarget
            name = target.val()

            if MC.aws.aws.checkResName( @model.get('uid'), target, "SG" )
                oldName = @model.get("name")
                @model.setName name

                @setTitle @model.get("name")
                @prependTitle '<span class="sg-color" style="background-color:' + @model.get("color") + '" ></span>'

                $("#sg-rule-list").children().find(".rule-reference").each ()->
                    if $(this).text() is oldName then $(this).html( title )
                    return
            null

        setSGDescription : ( event ) ->
            @model.setDescription event.target.value
            null

        sortSgRule : ( event ) ->
            @model.sortSGRule( $(event.target).find('.selected').attr('data-id') )
            @refreshSgruleList()
            null

        removeRulefromList: (event) ->
            li_dom = $(event.target).closest('li')
            rule =
                ruleSetId : li_dom.attr('data-uid')
                port      : li_dom.attr('data-port')
                protocol  : li_dom.attr('data-protocol')
                direction : li_dom.attr('data-direction')
                relation  : li_dom.attr("data-relationid")

            li_dom.remove()

            ruleCount = $("#sg-rule-list").children().length
            $("#rule-count").text ruleCount

            @model.removeRule rule
            false

        saveSgModal : ( event ) ->

            sg_direction        = $('#sg-modal-direction input:checked').val()
            descrition_dom      = $('#securitygroup-modal-description')
            tcp_port_dom        = $('#sg-protocol-tcp input')
            udp_port_dom        = $('#sg-protocol-udp input')
            custom_protocal_dom = $( '#sg-protocol-custom input' )
            protocol_type       = $('#modal-protocol-select').data('protocal-type')
            sourceValue         = $.trim($('#sg-add-model-source-select').find('.selected').attr('data-id'))

            # validation #####################################################
            validateMap =
                'custom':
                    dom: custom_protocal_dom
                    method: ( val ) ->
                        if not MC.validate.portRange(val)
                            return lang.PARSLEY.MUST_BE_A_VALID_FORMAT_OF_NUMBER
                        if Number(val) < 0 or Number(val) > 255
                            return lang.PARSLEY.THE_PROTOCOL_NUMBER_RANGE_MUST_BE_0_255
                        null
                'tcp':
                    dom: tcp_port_dom
                    method: ( val ) ->
                        portAry = []
                        portAry = MC.validate.portRange(val)
                        if not portAry
                            return lang.PARSLEY.MUST_BE_A_VALID_FORMAT_OF_PORT_RANGE
                        if not MC.validate.portValidRange(portAry)
                            return lang.PARSLEY.PORT_RANGE_BETWEEN_0_65535
                        null
                'udp':
                    dom: udp_port_dom
                    method: ( val ) ->
                        portAry = []
                        portAry = MC.validate.portRange(val)
                        if not portAry
                            return lang.PARSLEY.MUST_BE_A_VALID_FORMAT_OF_PORT_RANGE
                        if not MC.validate.portValidRange(portAry)
                            return lang.PARSLEY.PORT_RANGE_BETWEEN_0_65535
                        null

            if protocol_type of validateMap
                needValidate = validateMap[ protocol_type ]
                needValidate.dom.parsley 'custom', needValidate.method

            descrition_dom.parsley 'custom', ( val ) ->
                if !MC.validate 'cidr', val
                    return lang.PARSLEY.MUST_BE_CIDR_BLOCK
                null

            if (sourceValue is 'custom' and (not descrition_dom.parsley 'validate')) or (needValidate and not needValidate.dom.parsley 'validate')
                return
            # validation #####################################################

            rule = {
                protocol  : protocol_type
                direction : sg_direction || "inbound"
                fromPort  : ""
                toPort    : ""
            }

            switch protocol_type
                when "tcp", "udp"
                    ports = $( '#sg-protocol-' + protocol_type + ' input' ).val().split('-')

                    rule.fromPort = ports[0].trim()
                    if ports.length >= 2
                        rule.toPort = ports[1].trim()

                when "icmp"
                    protocol_val = $("#protocol-icmp-main-select").data('protocal-main')
                    protocol_val_sub = $("#protocol-icmp-main-select").data('protocal-sub')
                    rule.fromPort = protocol_val
                    rule.toPort   = protocol_val_sub

                when "custom"
                    rule.protocol = $( '#sg-protocol-custom input' ).val()

            if sourceValue is 'custom'
                rule.relation = descrition_dom.val()
            else
                rule.relation = "@" + $('#sg-add-model-source-select').children("ul").children('.selected').attr("data-uid")

            result = @model.addRule rule

            # Insert new rule
            if not result
                # the rule exist
                notification 'warning', lang.NOTIFY.THE_ADDING_RULE_ALREADY_EXIST
            else
                @refreshSgruleList()
                modal.close()
    }

    new SgView()
