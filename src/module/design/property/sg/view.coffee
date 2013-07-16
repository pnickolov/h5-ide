#############################
#  View(UI logic) for design/property/sg
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars', 'UI.editablelabel' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-sg-tmpl' ).html()

        events   :
            'click .secondary-panel .back' : 'openInstance'

            #for sg rule
            'click .rule-edit-icon' : 'showEditRuleModal'
            'click #sg-add-rule-icon' : 'showCreateRuleModal'
            'click .rule-remove-icon' : 'removeRulefromList'

            #for sg modal
            'click #sg-modal-direction input' : 'radioSgModalChange'
            'OPTION_CHANGE #modal-protocol-select' : 'sgModalSelectboxChange'
            'OPTION_CHANGE #protocol-icmp-main-select' : 'icmpMainSelect'
            'OPTION_CHANGE .protocol-icmp-sub-select' : 'icmpSubSelect'
            'click #sg-modal-save' : 'saveSgModal'
            'click .editable-label' : 'editablelabelClick'
            'change #sg-protocol-tcp input' : 'tcpValueChange'
            'change #sg-protocol-udp input' : 'udpValueChange'
            'change #sg-protocol-custom input' : 'customValueChange'

            #for sg detail
            'change #securitygroup-name' : 'setSGName'
            'change #securitygroup-description' : 'setSGDescription'

        render     : () ->
            console.log 'property:sg render'
            $( '.property-details' ).html this.template this.model.attributes
            fixedaccordion.resize()
            #
            secondary_panel_wrap = $('#sg-secondary-panel')
            secondary_panel_wrap.animate({
                right: 0
            }, {
                duration: 200,
                specialEasing: {
                    width: 'linear'
                },
                complete : () ->
                    selectbox.init()
                    $('#sg-secondary-panel .sg-title input').focus()
                }
            )

        openInstance : () ->
            console.log 'openInstance'
            secondary_panel_wrap = $('#sg-secondary-panel')
            secondary_panel_wrap.animate({
                right: "-280px"
            }, {
                duration: 500,
                specialEasing: {
                    width: 'linear'
                },
                complete : () ->
                    ide_event.trigger ide_event.OPEN_PROPERTY, $('#sg-secondary-panel').attr 'parent'
                }
            )

        securityGroupAddSelect: (event) ->
            fixedaccordion.show.call $('#sg-head')


        #SG SecondaryPanel
        showEditRuleModal : (event) ->
            modal MC.template.modalSGRule {isAdd:false}, true

        showCreateRuleModal : (event) ->
            isclassic = false
            if MC.canvas_data.platform == MC.canvas.PLATFORM_TYPE.EC2_CLASSIC
                isclassic = true
            modal MC.template.modalSGRule {isAdd:true, isclassic:isclassic}, true
            return false

        removeRulefromList: (event, id) ->
            rule = {}
            rule.inbound = $(event.target).parents('li').first().data('inbound')
            rule.protocol = $(event.target).parents('li').first().data('protocol')
            rule.fromport = $(event.target).parents('li').first().data('fromport')
            rule.toport = $(event.target).parents('li').first().data('toport')
            rule.iprange = $(event.target).parents('li').first().data('iprange')
            sg_uid = $("#sg-secondary-panel").attr "uid"
            this.trigger 'REMOVE_SG_RULE', sg_uid, rule
            $(event.target).parents('li').first().remove()

        radioSgModalChange : (event) ->
            if $('#sg-modal-direction input:checked').val() is "radio_inbound"
                $('#rule-modle-title2').text "Source"
            else
                $('#rule-modle-title2').text "Destination"

        sgModalSelectboxChange : (event, id) ->
            $('#sg-protocol-select-result').find('.show').removeClass('show')
            $('#sg-protocol-' + id).addClass('show')
            $('#modal-protocol-select').data('protocal-type', id)
            protocol_type = id
            protocol_val = ""
            protocol_val_sub = ""
            null

        icmpMainSelect : ( event, id ) ->
            $("#protocol-icmp-main-select").data('protocal-main', id)
            if id is 3 || id is 5 || id is 11 || id is 12
                $( '#protocol-icmp-sub-select-' + id).addClass('shown')
            else
                $('.protocol-icmp-sub-select').removeClass('shown')

        icmpSubSelect : ( event, id ) ->
            $("#protocol-icmp-main-select").data('protocal-sub', id)

        setSGName : ( event ) ->
            sg_uid = $("#sg-secondary-panel").attr "uid"
            this.trigger 'SET_SG_NAME', sg_uid, event.target.value

        setSGDescription : ( event ) ->

            sg_uid = $("#sg-secondary-panel").attr "uid"
            this.trigger 'SET_SG_DESC', sg_uid, event.target.value

        saveSgModal : ( event ) ->
            sg_direction = $('#sg-modal-direction input:checked').val()
            descrition_dom = $('#securitygroup-modal-description')
            rule = {}
            if(descrition_dom.hasClass('input'))
                sg_descrition = descrition_dom.val()
            else
                sg_descrition = descrition_dom.html()

            protocol_type =  $('#modal-protocol-select').data('protocal-type')
            rule.protocol = protocol_type
            protocol_val = $("#protocol-icmp-main-select").data('protocal-main')
            protocol_val_sub = $("#protocol-icmp-main-select").data('protocal-sub')
            switch protocol_type
                when "tcp", "udp"
                    protocol_val = $( '#sg-protocol-tcp input' ).val()
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
            rule.ipranges = sg_descrition

            sg_uid = $("#sg-secondary-panel").attr "uid"

            this.trigger "SET_SG_RULE", sg_uid, rule


        editablelabelClick : ( event ) ->
            editablelabel.create.call $(event.target)

        tcpValueChange : ( event ) ->
            protocol_val = $( '#sg-protocol-tcp input' ).val()
            null

        udpValueChange : ( event ) ->
            protocol_val = $( '#sg-protocol-udp input' ).val()
            null

        customValueChange : ( event ) ->
            protocol_val = $( '#sg-protocol-custom input' ).val()
            null
    }

    view = new InstanceView()

    return view