#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars',
        'UI.selectbox',
        'UI.tooltip',
        'UI.notification',
        'UI.modal',
        'UI.tablist',
        'UI.toggleicon' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-instance-tmpl' ).html()

        events   :
            'change .instance-name'                             : 'instanceNameChange'
            'change #property-instance-count'                   : 'countChange'
            'change .instance-type-select'                      : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized'           : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch'       : 'cloudwatchSelect'
            'change #property-instance-user-data'               : 'userdataChange'
            'change #property-instance-base64'                  : 'base64Change'
            'change #property-instance-ni-description'          : 'eniDescriptionChange'
            'change #property-instance-source-check'            : 'sourceCheckChange'
            'change #property-instance-public-ip'               : 'publicIpChange'
            'OPTION_CHANGE #instance-type-select'               : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select'                     : "tenancySelect"
            'OPTION_CHANGE #keypair-select'                     : "addtoKPList"
            'EDIT_UPDATE #keypair-select'                       : "createtoKPList"
            'click #instance-ip-add'                            : "addIPtoList"
            'click #property-network-list .network-remove-icon' : "removeIPfromList"

            'change .input-ip'    : 'updateEIPList'
            'click .toggle-eip'   : 'addEIP'
            'click #property-ami' : 'openAmiPanel'

        render     : ( attributes ) ->
            console.log 'property:instance render'
            #
            this.undelegateEvents()

            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                this.model.attributes.component.resource.VpcId = defaultVPCId

            $( '.property-details' ).html this.template this.model.attributes

            this.delegateEvents this.events

        instanceNameChange : ( event ) ->
            console.log 'instanceNameChange'

            target = $ event.currentTarget
            name = target.val()
            id = @model.get 'get_uid'


            MC.validate.preventDupname target, id, name, 'Instance'


            if target.parsley 'validate'
                this.model.set 'name', name
            null

        countChange : ( event ) ->
            target = $ event.currentTarget

            target.parsley 'custom', ( val ) ->
                if isNaN( val ) or val > 99 or val < 1
                    return 'This value must be >= 1 and <= 99'

            if target.parsley 'validate'
                @trigger "COUNT_CHANGE", +target.val()

        instanceTypeSelect : ( event, value )->
            this.model.set 'instance_type', value

        ebsOptimizedSelect : ( event ) ->
            this.model.set 'ebs_optimized', event.target.checked

        tenancySelect : ( event, value ) ->
            this.model.set 'tenacy', value

        cloudwatchSelect : ( event ) ->
            this.model.set 'cloudwatch', event.target.checked
            $("#property-cloudwatch-warn").toggle( $("#property-instance-enable-cloudwatch").is(":checked") )

        userdataChange : ( event ) ->
            this.model.set 'user_data', event.target.value

        base64Change : ( event ) ->
            this.model.set 'base64', event.target.checked

        eniDescriptionChange : ( event ) ->
            this.model.set 'eni_description', event.target.value

        sourceCheckChange : ( event ) ->
            this.model.set 'source_check', event.target.checked

        publicIpChange : ( event ) ->

            this.model.set 'public_ip', event.target.checked

        addEmptyKP : ( event ) ->
            notification('error', 'KeyPair Empty', false)

        addtoKPList : ( event, id ) ->
            this.model.set 'set_kp', id
            notification('info', (id + ' added'), false)
            this.trigger 'REFRESH_KEYPAIR'

        createtoKPList : ( event, id ) ->
            this.model.set 'add_kp', id

        addIPtoList: (event) ->

            tmpl = $(MC.template.networkListItem())

            index = $('#property-network-list').children().length

            tmpl.children()[1] = $(tmpl.children()[1]).data("index", index).attr('data-index', index)[0]

            $('#property-network-list').append tmpl
            this.trigger 'ADD_NEW_IP'

            this.updateEIPList()

            false

        removeIPfromList: (event, id) ->

            index = $($(event.target).parents('li').first().children()[1]).data().index

            $(event.target).parents('li').first().remove()

            $.each $("#property-network-list").children(), (idx, val) ->

                $($(val).children()[1]).data('index', idx)

                $($(val).children()[1]).attr('data-index', idx)

            this.trigger 'REMOVE_IP', index

            this.updateEIPList()

        openAmiPanel : ( event ) ->
            console.log 'openAmiPanel'
            target = $('#property-ami')
            ###
            secondarypanel.open target, MC.template.aimSecondaryPanel target.data('secondarypanel-data')
            $(document.body).on 'click', '.back', secondarypanel.close
            ###
            console.log MC.template.aimSecondaryPanel target.data( 'secondarypanel-data' )

            data = target.data( 'secondarypanel-data' )
            ide_event.trigger ide_event.PROPERTY_OPEN_SUBPANEL, {
                title : data.imageId
                dom   : MC.template.aimSecondaryPanel data
                id    : 'Ami'
            }
            null

        addEIP : ( event ) ->

            # todo, need a index of eip
            index = parseInt event.target.dataset.index, 10
            if event.target.className.indexOf('associated') >= 0 then attach = true else attach = false
            this.trigger 'ATTACH_EIP', index, attach

            this.updateEIPList()

        updateEIPList: (event) ->

            currentAvailableIPAry = []
            ipInuptListItem = $('#property-network-list li')

            _.each ipInuptListItem, (ipInputItem) ->
                inputValuePrefix = $(ipInputItem).find('.input-ip-prefix').text()
                inputValue = $(ipInputItem).find('.input-ip').val()
                inputHaveEIP = $(ipInputItem).find('.input-ip-eip-btn').hasClass('associated')
                currentAvailableIPAry.push({
                    ip: inputValuePrefix + inputValue,
                    eip: inputHaveEIP
                })
                null

            this.trigger 'SET_IP_LIST', currentAvailableIPAry
    }

    view = new InstanceView()

    return view
