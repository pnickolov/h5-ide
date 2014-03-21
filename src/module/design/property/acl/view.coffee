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
            'change #property-acl-name'                 : 'aclNameChanged'
            'click #acl-add-rule-icon'                  : 'showCreateRuleModal'
            'OPTION_CHANGE #acl-sort-rule-select'       : 'sortAclRule'
            'click .acl-rule-details .rule-remove-icon' : 'removeAclRule'

        render : () ->
            @$el.html htmlTpl @model.attributes

            @refreshRuleList()

            @model.attributes.name

        aclNameChanged : (event) ->
            target = $ event.currentTarget
            name = target.val()

            if @checkResName( target, "ACL" )
                @model.setName name
                @setTitle name

        sortAclRule : ( event ) ->
            sg_rule_list = $('#acl-rule-list')

            sortType = $(event.target).find('.selected').attr('data-id')

            @model.setSortOption( sortType )
            @refreshRuleList()
            null

        refreshRuleList : () ->
            $('#acl-rule-list').html ruleTpl @model.attributes.rules
            $('#acl-rule-count').text(@model.attributes.rules.length)
            null

        removeAclRule : (event) ->
            $target = $( event.currentTarget ).closest("li")
            ruleId  = $target.attr("data-uid")

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

            # Number
            $rule_number_dom = $('#modal-acl-number')
            number = $('#modal-acl-number').val()
            result = @model.checkRuleNumber( number )
            $rule_number_dom.parsley 'custom', ( val ) ->
                if _.isString result then result else null

            if not $rule_number_dom.parsley 'validate'
                return


            # Source
            source = $('#acl-add-model-source-select').find('.selected').attr('data-id')
            if source is "custom"

                $custom_source_dom = $('#modal-acl-source-input')
                $custom_source_dom.parsley 'custom', ( val ) ->
                    if !MC.validate 'cidr', val
                        return lang.ide.PARSLEY_MUST_BE_CIDR_BLOCK
                    null

                if not $custom_source_dom.parsley 'validate'
                    return

                source = $custom_source_dom.val()

            # Protocol Validate
            $protocol_dom = $('#modal-protocol-select').find('.selected')
            protocol      = $protocol_dom.attr('data-id')
            validateMap   =
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

            if validateMap[ protocol ]
                needValidate = validateMap[ protocol ]
                needValidate.dom.parsley 'custom', needValidate.method
                if not needValidate.dom.parsley 'validate'
                    return

            #####
            if protocol is 'tcp'
                port     = $('#sg-protocol-' + protocol + ' input').val()
                protocol = "6"

            else if protocol is 'udp'
                port     = $('#sg-protocol-' + protocol + ' input').val()
                protocol = '17'

            else if protocol is 'icmp'
                icmpType = $('#protocol-icmp-main-select').find('.selected').attr('data-id')
                icmpCode = $('#protocol-icmp-sub-select-' + icmpType).find('.selected').attr('data-id') || "-1"

                protocol = '1'
                port     = icmpType + "/" + icmpCode

            else if protocol is 'custom'
                protocol = $('#sg-protocol-' + protocol + ' input').val()
                port     = ""

            else if protocol is 'all'
                protocol = '-1'
                port     = ''


            @model.addAclRule {
                number   : number
                action   : if $('#acl-add-model-action-allow').is(':checked') then "allow" else "deny"
                egress   : $('#acl-add-model-direction-outbound').is(':checked')
                cidr     : source

                protocol : protocol
                port     : port
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
