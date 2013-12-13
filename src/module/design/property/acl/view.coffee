#############################
#  View(UI logic) for design/property/acl
#############################

define [ '../base/view',
         'Design',
         'constant'
         'text!./template/stack.html',
         'text!./template/rule_item.html',
         'text!./template/dialog.html',
         'i18n!nls/lang.js'
], ( PropertyView, Design, constant, htmlTpl, ruleTpl, rulePopupTpl, lang ) ->

    htmlTpl  = Handlebars.compile htmlTpl
    ruleTpl  = Handlebars.compile ruleTpl
    rulePopupTpl = Handlebars.compile rulePopupTpl

    ACLView = PropertyView.extend {

        events   :
            'change #property-acl-name'           : 'aclNameChanged'
            'click #acl-add-rule-icon'            : 'showCreateRuleModal'
            'OPTION_CHANGE #acl-sort-rule-select' : 'sortACLRule'
            'click .rule-list-row .icon-remove'   : 'removeACLRule'

        render : () ->
            @$el.html htmlTpl @model.attributes
            @model.attributes.name

        aclNameChanged : (event) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkDupName( target, "ACL" )
                @model.setName name
                @setTitle name

        sortACLRule : ( event ) ->
            sg_rule_list = $('#acl-rule-list')

            sortType = $(event.target).find('.selected').attr('data-id')

            @model.setSortOption( sortType )
            @refreshRuleList()
            null

        refreshRuleList : () ->
            $('#acl-rule-list').html ruleTpl @model.attributes.rules
            $('#acl-rule-count').text(@model.attributes.rules.length)
            null

        removeACLRule : (event) ->
            $target = $( event.currentTarget ).closest("li")
            ruleId  = $target.attr("data-id")

            if @model.removeAclRule ruleId
                $target.remove()
            null

        showCreateRuleModal : () ->

            SubnetModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )

            data = {
                classic : Design.instance().typeIsClassic()
                subnets : _.map SubnetModel.allObjects(), ( subnet )->
                    {
                        name : subnet.get("name")
                        cidr : subnet.get("cidr")
                    }
            }

            modal rulePopupTpl( data )

            # Bind Modal Events
            $("#acl-modal-rule-save-btn").on("click", _.bind( @saveRule, @ ))
            $("#acl-add-model-source-select").on("OPTION_CHANGE", @modalRuleSourceSelected )
            $("#modal-protocol-select").on("OPTION_CHANGE", @modalRuleProtocolSelected )
            $("#protocol-icmp-main-select").on("OPTION_CHANGE", @modalRuleICMPSelected )
            $("#acl-add-model-direction-outbound").on("change", @changeBoundInModal )
            $("#acl-add-model-direction-inbound").on("change", @changeBoundInModal )
            $('.simple-protocol-select li').on('click', @clickSimpleProtocolSelect)
            return false

        saveRule : () ->

            that = this
            aclUID = that.model.get('component').uid
            aclName = that.model.get('component').name

            rule_number_dom =  $('#modal-acl-number')
            ruleNumber = $('#modal-acl-number').val()
            action = $('#acl-add-model-action-allow').prop('checked')
            inboundDirection = $('#acl-add-model-direction-inbound').prop('checked')
            source = $.trim($('#acl-add-model-source-select').find('.selected').attr('data-id'))
            custom_source_dom = $('#modal-acl-source-input')

            if custom_source_dom.is(':visible')
                source = custom_source_dom.val()

            protocol_dom = $('#modal-protocol-select').find('.selected')
            protocol = $.trim(protocol_dom.attr('data-id'))
            protocolStr = $.trim(protocol_dom.attr('data-id'))

            port = $('#acl-rule-modal-port-input').val()

            ruleAction = ''
            if action
                ruleAction = 'allow'
            else
                ruleAction = 'deny'

            egress = ''
            if inboundDirection
                egress = 'false'
            else
                egress = 'true'

            # validation #####################################################
            validateMap =
                'tcp':
                    dom: $('#sg-protocol-tcp input')
                    method: ( val ) ->
                        portAry = []
                        portAry = MC.validate.portRange(val)
                        if not portAry
                            return 'Must be a valid format of port range.'
                        if not MC.validate.portValidRange(portAry)
                            return 'Port range needs to be a number or a range of numbers between 0 and 65535.'
                        null
                'udp':
                    dom: $('#sg-protocol-udp input')
                    method: ( val ) ->
                        portAry = []
                        portAry = MC.validate.portRange(val)
                        if not portAry
                            return 'Must be a valid format of port range.'
                        if not MC.validate.portValidRange(portAry)
                            return 'Port range needs to be a number or a range of numbers between 0 and 65535.'
                        null
                'custom':
                    dom: $('#sg-protocol-custom input')
                    method: ( val ) ->
                        if not MC.validate.port(val)
                            return 'Must be a valid format of port.'
                        null

            if protocolStr of validateMap
                needValidate = validateMap[ protocolStr ]
                needValidate.dom.parsley 'custom', needValidate.method

            custom_source_dom.parsley 'custom', ( val ) ->
                if !MC.validate 'cidr', val
                    return 'Must be a valid form of CIDR block.'
                null

            rule_number_dom.parsley 'custom', ( val ) ->
                if Number(val) > 32767
                    return 'The maximum value is 32767.'
                if that.model.haveRepeatRuleNumber(aclUID, val)
                    return 'The Rule Number have exist one.'
                if aclName is 'DefaultACL' and Number(val) is 100
                    return 'The DefaultACL\'s Rule Number 100 has existed.'
                null

            if (not rule_number_dom.parsley 'validate') or (custom_source_dom.is(':visible') and not custom_source_dom.parsley 'validate') or
                (needValidate and not needValidate.dom.parsley 'validate')
                    return
            # validation #####################################################

            icmpType = icmpCode = ''
            if protocol is 'tcp'
                portRangeStr = $('#sg-protocol-' + protocol + ' input').val()
                portRangeAry = MC.validate.portRange(portRangeStr)
                if portRangeAry.length is 2
                    portFrom = portRangeAry[0]
                    portTo = portRangeAry[1]
                else
                    portTo = portFrom = portRangeAry[0]
                protocol = '6'
            else if protocol is 'udp'
                portRangeStr = $('#sg-protocol-' + protocol + ' input').val()
                portRangeAry = MC.validate.portRange(portRangeStr)
                if portRangeAry.length is 2
                    portFrom = portRangeAry[0]
                    portTo = portRangeAry[1]
                else
                    portTo = portFrom = portRangeAry[0]
                protocol = '17'
            else if protocol is 'icmp'
                portTo = portFrom = ''
                icmpType = $('#protocol-icmp-main-select').find('.selected').attr('data-id')
                icmpCode = $('#protocol-icmp-sub-select-' + icmpType).find('.selected').attr('data-id')
                if !icmpCode
                    icmpCode = '-1'
                protocol = '1'
            else if protocol is 'custom'
                protocol = $('#sg-protocol-' + protocol + ' input').val()
                portTo = portFrom = ''
            else if protocol is 'all'
                portFrom = '0'
                portTo = '65535'
                protocol = '-1'

            @model.addRuleToACL {
                rule: ruleNumber,
                action: ruleAction,
                egress: egress,
                source: source,
                protocol: protocol,
                portTo: portTo
                portFrom: portFrom
                type: icmpType
                code: icmpCode
            }

            modal.close()

            null

        modalRuleSourceSelected : (event) ->
            value = $.trim($(event.target).find('.selected').attr('data-id'))

            if value is 'custom'
                $('#modal-acl-source-input').show()
                $('#acl-add-model-source-select .selection').width(68)
            else
                $('#modal-acl-source-input').hide()
                $('#acl-add-model-source-select .selection').width(322)

        modalRuleProtocolSelected : (event) ->
            protocolSelectElem = $(event.target)
            selectedValue = protocolSelectElem.find('.selected').attr('data-id')

            if selectedValue

                $('#sg-protocol-custom').hide()
                $('#sg-protocol-all').hide()

                $('#sg-protocol-select-result .sg-protocol-option-input').hide()
                $('#sg-protocol-' + selectedValue).show()

                icmpSelectElem = $('#protocol-icmp-main-select')
                icmpSelectedValue = icmpSelectElem.find('.selected').attr('data-id')
                if icmpSelectedValue isnt '3' and icmpSelectedValue isnt '5' and icmpSelectedValue isnt '11' and icmpSelectedValue isnt '12'
                    $('.protocol-icmp-sub-select').hide()

            null

        modalRuleICMPSelected : (event) ->
            icmpSelectElem = $(event.target)
            selectedValue = icmpSelectElem.find('.selected').attr('data-id')
            subSelectElem = $('#protocol-icmp-sub-select-' + selectedValue)
            $('.protocol-icmp-sub-select').hide()
            subSelectElem.show()
            null

        changeBoundInModal : (event) ->

            inbound = $('#acl-add-model-direction-inbound').prop('checked')
            if inbound
                $('#acl-add-model-bound-label').text(lang.ide.POP_ACLRULE_LBL_SOURCE)
            else
                $('#acl-add-model-bound-label').text(lang.ide.POP_ACLRULE_LBL_DEST)

        clickSimpleProtocolSelect : (event) ->
            protocolName = $(event.currentTarget).text()

            toggleToProtocol = (protocolName) ->
                # protocolName is TCP ot UDP
                protocolNameLowerCase = protocolName.toLowerCase()
                selectBox = $('#modal-protocol-select')
                selectBox.find('li.item').removeClass('selected')
                selectBox.find('li.item[data-id=' + protocolNameLowerCase + ']').addClass('selected')
                selectBox.find('.selection').text(protocolName)
                selectBox.trigger('OPTION_CHANGE')

            protocolMap = {
                'SSH': 22,
                'SMTP': 25,
                'DNS': 53,
                'HTTP': 80,
                'POP3': 110,
                'IMAP': 143,
                'LDAP': 289,
                'HTTPS': 443,
                'SMTPS': 465,
                'IMAPS': 993,
                'POP3S': 995,
                'MS SQL': 1433,
                'MYSQL': 3306,
                'RDP': 3389
            }

            protocolPort = protocolMap[protocolName]

            if protocolName is 'DNS'
                toggleToProtocol('UDP')
                $('#sg-protocol-udp input').val(protocolPort)
            else
                toggleToProtocol('TCP')
                $('#sg-protocol-tcp input').val(protocolPort)
    }

    new ACLView()
