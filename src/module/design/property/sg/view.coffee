#############################
#  View(UI logic) for design/property/sg
#############################

define [ '../base/view',
         'text!./template/stack.html',
         'text!./template/app.html',
         'text!./template/rule_item.html',
         'constant',
         'i18n!nls/lang.js'
], ( PropertyView, template, app_template, rule_item_template, constant, lang ) ->

    template           = Handlebars.compile template
    app_template       = Handlebars.compile app_template
    rule_item_template = Handlebars.compile rule_item_template

    SgView = PropertyView.extend {

        events   :
            #for sg rule
            'click .rule-edit-icon'   : 'showEditRuleModal'
            'click #sg-add-rule-icon' : 'showCreateRuleModal'
            'click .rule-remove-icon' : 'removeRulefromList'

            #for sg detail
            'change #securitygroup-name'           : 'setSGName'
            'change #securitygroup-description'    : 'setSGDescription'
            'OPTION_CHANGE #sg-rule-filter-select' : 'sortSgRule'


        render : () ->
            if @model.isReadOnly
                tpl = app_template
            else
                tpl = template

            @$el.html tpl @model.attributes

            # change sg color for header
            sgUID = @model.get 'uid'
            sgName = @model.get 'name'
            sgColor = MC.aws.sg.getSGColor(sgUID)
            $('#property-second-title').html('<div class="sg-color sg-color-header" style="background-color:' + sgColor + '" ></div>' + sgName)

            @forceShow()

            # The secondary property will slide out.
            # We need to focus the input after it finishes transition
            setTimeout () ->
                $('#securitygroup-name').focus()
            , 200

            @model.get "name"

        #SG SecondaryPanel
        bindRuleModelEvent : ()->
            $("#sg-modal-direction").on("click", "input", @radioSgModalChange )
            $("#modal-protocol-select").on("OPTION_CHANGE", @sgModalSelectboxChange )
            $("#protocol-icmp-main-select").on("OPTION_CHANGE", @icmpMainSelect )
            $("#sg-protocol-select-result").on("OPTION_CHANGE", ".protocol-icmp-sub-select", @icmpSubSelect )
            $("#sg-modal-save").on("click", _.bind( @saveSgModal, @ ))
            $("#sg-add-model-source-select").on("OPTION_CHANGE", @modalRuleSourceSelected)
            null

        showEditRuleModal : (event) ->
            modal MC.template.modalSGRule {isAdd:false}, true
            @bindRuleModelEvent()

        showCreateRuleModal : (event) ->
            isclassic = MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC

            # get sg list
            sgList = []
            _.each MC.canvas_data.component, (compObj) ->
                if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
                    if !MC.aws.elb.isELBDefaultSG(compObj.uid)
                        sgColor = MC.aws.sg.getSGColor(compObj.uid)
                        sgList.push({
                            sgName: compObj.name
                            sgUID: compObj.uid
                            sgColor: sgColor
                        })
                null


            modal MC.template.modalSGRule {isAdd:true, isclassic: isclassic, sgList: sgList}, true

            @bindRuleModelEvent()
            return false

        removeRulefromList: (event) ->
            li_dom = $(event.target).parents('li').first()
            rule =
                inbound  : li_dom.data('inbound')
                protocol : li_dom.data('protocol')
                fromport : li_dom.data('fromport')
                toport   : li_dom.data('toport')
                iprange  : li_dom.data('iprange')

            li_dom.remove()

            ruleCount = $("#sg-rule-list").children().length
            $("#sg-rule-empty").toggle ruleCount == 0
            $("#rule-count").text ruleCount

            @model.removeSGRule rule
            null

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

        setSGName : ( event ) ->
            id = @model.get 'uid'
            target = $ event.currentTarget
            name = target.val()

            MC.validate.preventDupname target, id, name, 'SG'

            if target.parsley 'validate'
                @trigger 'NAME_CHANGE', name
                @model.setSGName name
            null

        setSGDescription : ( event ) ->
            @model.setSGDescription event.target.value
            null

        saveSgModal : ( event ) ->

            that = this

            sg_direction = $('#sg-modal-direction input:checked').val()
            descrition_dom = $('#securitygroup-modal-description')
            tcp_port_dom = $('#sg-protocol-tcp input')
            udp_port_dom = $('#sg-protocol-udp input')
            custom_protocal_dom = $( '#sg-protocol-custom input' )
            protocol_type =  $('#modal-protocol-select').data('protocal-type')
            rule = {}

            sourceValue = $.trim($('#sg-add-model-source-select').find('.selected').attr('data-id'))

            sgUID = ''
            sgName = ''
            if descrition_dom.hasClass('input')
                if sourceValue isnt 'custom'
                    selectDom = $('#sg-add-model-source-select').find('.selected')
                    sgUID = selectDom.attr('data-sg-uid')
                    sgName = selectDom.text()
                    sg_descrition = '@' + sgUID + '.resource.GroupId'
                else
                    sg_descrition = descrition_dom.val()
            else
                sg_descrition = descrition_dom.html()

            # validation #####################################################
            validateMap =
                'custom':
                    dom: custom_protocal_dom
                    method: ( val ) ->
                        if not MC.validate.portRange(val)
                            return 'Must be a valid format of number.'
                        if Number(val) < 0 or Number(val) > 255
                            return 'The protocol number range must be 0-255.'
                        null
                'tcp':
                    dom: tcp_port_dom
                    method: ( val ) ->
                        portAry = []
                        portAry = MC.validate.portRange(val)
                        if not portAry
                            return 'Must be a valid format of port range.'
                        if not MC.validate.portValidRange(portAry)
                            return 'Port range needs to be a number or a range of numbers between 0 and 65535.'
                        null
                'udp':
                    dom: udp_port_dom
                    method: ( val ) ->
                        portAry = []
                        portAry = MC.validate.portRange(val)
                        if not portAry
                            return 'Must be a valid format of port range.'
                        if not MC.validate.portValidRange(portAry)
                            return 'Port range needs to be a number or a range of numbers between 0 and 65535.'
                        null

            if protocol_type of validateMap
                needValidate = validateMap[ protocol_type ]
                needValidate.dom.parsley 'custom', needValidate.method

            descrition_dom.parsley 'custom', ( val ) ->
                if !MC.validate 'cidr', val
                    return 'Must be a valid form of CIDR block.'
                null

            if (sourceValue is 'custom' and (not descrition_dom.parsley 'validate')) or (needValidate and not needValidate.dom.parsley 'validate')
                return
            # validation #####################################################

            rule.protocol = protocol_type
            protocol_val = $("#protocol-icmp-main-select").data('protocal-main')
            protocol_val_sub = $("#protocol-icmp-main-select").data('protocal-sub')
            switch protocol_type
                when "tcp", "udp"
                    protocol_val = $( '#sg-protocol-' + protocol_type + ' input' ).val()
                    if '-' in protocol_val
                        rule.fromport = protocol_val.split('-')[0].trim()
                        rule.toport = protocol_val.split('-')[1].trim()
                    else
                        rule.fromport = protocol_val
                        rule.toport = protocol_val

                when "icmp"
                    rule.fromport = protocol_val
                    rule.toport = protocol_val_sub

                when "custom"
                    rule.protocol = $( '#sg-protocol-custom input' ).val()
                    rule.fromport = ""
                    rule.toport = ""

                when "all"
                    rule.protocol = -1
                    rule.fromport = ""
                    rule.toport = ""

            rule.direction = sg_direction

            if sourceValue is 'custom'
                rule.ipranges = sg_descrition
            else
                rule.ipranges = sgName

            rule.ipranges = sg_descrition

            data = @model.addSGRule rule

            # Insert new rule
            
            # the rule is exist
            if not data
                notification 'warning', lang.ide.PROP_WARN_SG_RULE_EXIST
            else
                data.ruleEditable = that.model.get('ruleEditable')

                $("#sg-rule-list").append rule_item_template data

                MC.canvas.reDrawSgLine()

                modal.close()

        modalRuleSourceSelected : (event) ->
            value = $.trim($(event.target).find('.selected').attr('data-id'))
            isCustom = value is 'custom'
            $('#securitygroup-modal-description').toggle( isCustom )
            $('#sg-add-model-source-select .selection').width( if isCustom then 69 else 322 )
            null

        sortSgRule : ( event ) ->
            sg_rule_list = $('#sg-rule-list')

            sortType = $(event.target).find('.selected').attr('data-id')

            sorted_items = $('#sg-rule-list li')
            if sortType is 'direction'
                sorted_items = sorted_items.sort(this._sortDirection)
            else if sortType is 'source/destination'
                sorted_items = sorted_items.sort(this._sortSource)
            else if sortType is 'protocol'
                sorted_items = sorted_items.sort(this._sortProtocol)

            sg_rule_list.html sorted_items

        _sortDirection : ( a, b) ->
            return $(a).attr('data-direction') >
                $(b).attr('data-direction')

        _sortProtocol : ( a, b) ->
            return $(a).attr('data-protocol') >
                $(b).attr('data-protocol')

        _sortSource : ( a, b) ->
            return $(a).attr('data-iprange') >
                $(b).attr('data-iprange')
    }

    new SgView()
