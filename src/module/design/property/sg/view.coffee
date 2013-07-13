#############################
#  View(UI logic) for design/property/sg
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-sg-tmpl' ).html()

        events   :
            'click .secondary-panel .back' : 'openInstance'

            #for sg module
            'click .rule-edit-icon' : 'showEditRuleModal'
            'click #sg-add-rule-icon' : 'showCreateRuleModal'
            'click .rule-remove-icon' : 'removeRulefromList'
            'change #radio_inbound' : 'radioInboundChange'
            'change #radio_outbound' : 'radioOutboundChange'
            'OPTION_CHANGE #modal-sg-rule' : 'sgModalSelectboxChange'

            'change #securitygroup-name' : 'setSGName'
            'click #sg-modal-save': 'modalSaveClick'

        render     : () ->
            console.log 'property:sg render'
            $( '.property-details' ).html this.template this.model.attributes
            #
            $('#sg-secondary-panel').fadeIn 200
            $('#sg-secondary-panel .sg-title input').focus()
            fixedaccordion.resize()
            selectbox.init()

        openInstance : () ->
            console.log 'openInstance'
            secondarypanel.close
            ide_event.trigger ide_event.OPEN_PROPERTY, $('#sg-secondary-panel').attr 'parent'

        securityGroupAddSelect: (event) ->
            fixedaccordion.show.call $('#sg-head')


        #SG SecondaryPanel
        showEditRuleModal : (event) ->
            modal MC.template.modalSGRule {isAdd:false}, true

        showCreateRuleModal : (event) ->
            modal MC.template.modalSGRule {isAdd:true}, true
            return false

        removeRulefromList: (event, id) ->
            target = $(event.target).parents('li').first()
            rule_id = target.data('ruleid')
            console.log rule_id
            $(event.target).parents('li').first().remove()

        radioInboundChange : (event) ->
            $('#rule-modle-title2').text "Source"

        radioOutboundChange : (event) ->
            $('#rule-modle-title2').text "Destination"

        sgModalSelectboxChange : (event, id) ->
            $('#sg-protocol-select-result').find('.show').removeClass('show')
            $('#sg-protocol-' + id).addClass('show')

        setSGName : ( event ) ->
            sg_uid = $("#sg-secondary-panel").attr "uid"

            this.trigger 'SET_SG_NAME', sg_uid, event.target.value

        modalSaveClick : (event) ->
            console.log 'sg-modal-save'
    }

    view = new InstanceView()

    return view