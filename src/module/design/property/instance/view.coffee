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
            'change .instance-name'                       : 'instanceNameChange'
            'change #property-instance-count'             : 'countChange'
            'change .instance-type-select'                : 'instanceTypeSelect'
            'change #property-instance-ebs-optimized'     : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data'         : 'userdataChange'
            'change #property-instance-base64'            : 'base64Change'
            'change #property-instance-ni-description'    : 'eniDescriptionChange'
            'change #property-instance-source-check'      : 'sourceCheckChange'
            'change #property-instance-public-ip'         : 'publicIpChange'
            'OPTION_CHANGE #instance-type-select'         : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select'               : "tenancySelect"
            'OPTION_CHANGE #keypair-select'               : "addtoKPList"
            'EDIT_UPDATE #keypair-select'                 : "createtoKPList"
            'click #instance-ip-add'                      : "addIPtoList"
            'click #property-network-list .icon-remove'   : "removeIPfromList"

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

            $( "#keypair-select" ).on("click", ".icon-remove", _.bind(this.deleteKP, this) )

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
                val = +target.val()
                @trigger "COUNT_CHANGE", val
                $(".property-instance-name-wrap").toggleClass("single", val == 1)
                $("#property-instance-name-count").text val
                @setEditableIP val == 1

        setEditableIP : ( enable ) ->
            $parent = $("#property-network-list")

            if enable
                $parent.find(".input-ip").removeAttr "disabled"
                $parent.find(".name").data "tooltip", "Specify an IP address or leave it as .x to automatically assign an IP."

            else
                $parent.find(".input-ip").attr "disabled", "disabled"
                $parent.find(".name").data "tooltip", "Automatically assigned IP."

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

        addtoKPList : ( event, id ) ->
            this.model.set 'set_kp', id
            this.trigger 'REFRESH_KEYPAIR'

        createtoKPList : ( event, id ) ->
            this.model.set 'add_kp', id

        addIPtoList: (event) ->

            subnetCIDR = ''
            instanceUID = this.model.get 'get_uid'
            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(instanceUID)
                subnetCIDR = subnetObj.cidrBlock
            else
                subnetUID = MC.canvas_data.component[instanceUID].resource.SubnetId.split('.')[0][1...]
                subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

            ipPrefixSuffix = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)
            tmpl = $(MC.template.networkListItem({
                ipPrefix: ipPrefixSuffix[0],
                ipSuffix: ipPrefixSuffix[1]
            }))

            $('#property-network-list').append tmpl
            this.trigger 'ADD_NEW_IP'

            this.updateEIPList()
            false

        removeIPfromList: (event, id) ->

            $li = $(event.currentTarget).closest("li")
            index = $li.index()
            $li.remove()

            this.trigger 'REMOVE_IP', index

            this.updateEIPList()

        openAmiPanel : ( event ) ->
            console.log 'openAmiPanel'
            target = $('#property-ami')

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
            index = $(event.currentTarget).closest("li").index()
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


        deleteKP : ( event ) ->
            $li = $(event.currentTarget).closest("li")

            selected = $li.hasClass("selected")
            using = if using is "true" then true else selected

            removeKP = () ->

                $li.remove()
                # If deleting selected kp, select the first one
                if selected
                    $("#keypair-select").find(".item").eq(0).click()

                ###
                this.model.deleteKP $li.attr("data-id")
                ###

            if using
                data =
                    title   : "Delete Key Pair"
                    confirm : "Delete"
                    color   : "red"
                    body    : "<p><b>Are you sure you want to delete #{$li.text()}</b></p><p>Other instance using this key pair will change automatically to use DefaultKP."
                # Ask for confirm
                modal MC.template.modalApp data
                $("#btn-confirm").one "click", ()->
                    removeKP()
                    modal.close()
                null
            else
                removeKP()

            return false
    }

    view = new InstanceView()

    return view
