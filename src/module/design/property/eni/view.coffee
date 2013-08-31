#############################
#  View(UI logic) for design/property/eni
#############################

define [ 'event',
         'backbone',
         'jquery',
         'handlebars',
         'UI.tooltip',
         'UI.tablist' ], ( ide_event ) ->

   ENIView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-eni-tmpl' ).html()

        events   :

            "change #property-eni-desc" : "setEniDesc"
            "change #property-eni-source-check" : "setEniSourceDestCheck"

            'click #property-eni-ip-add' : "addIPtoList"
            'click #property-eni-list .network-remove-icon' : "removeIPfromList"

            'click .toggle-eip' : 'addEIP'

            'blur .input-ip' : 'updateEIPList'

        render     : () ->
            console.log 'property:eni render'
            $('.property-details').html this.template this.model.attributes

        setEniDesc : ( event ) ->

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger "SET_ENI_DESC", uid, event.target.value

        setEniSourceDestCheck : ( event ) ->

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger "SET_ENI_SOURCE_DEST_CHECK", uid, event.target.checked

        addIPtoList : ( event ) ->

            subnetCIDR = ''
            eniUID = this.model.get 'uid'
            defaultVPCId = MC.aws.aws.checkDefaultVPC()
            if defaultVPCId
                subnetObj = MC.aws.vpc.getSubnetForDefaultVPC(eniUID)
                subnetCIDR = subnetObj.cidrBlock
            else
                subnetUID = MC.canvas_data.component[eniUID].resource.SubnetId.split('.')[0][1...]
                subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock

            ipPrefixSuffix = MC.aws.subnet.genCIDRPrefixSuffix(subnetCIDR)
            tmpl = $(MC.template.networkListItem({
                ipPrefix: ipPrefixSuffix[0],
                ipSuffix: ipPrefixSuffix[1]
            }))

            index = $('#property-eni-list').children().length

            tmpl.children()[1] = $(tmpl.children()[1]).data("index", index).attr('data-index', index)[0]

            $('#property-eni-list').append tmpl

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger 'ADD_NEW_IP', uid

            this.updateEIPList()

        addEIP : ( event ) ->

            # todo, need a index of eip
            index = parseInt event.target.dataset.index, 10

            if event.target.className.indexOf('associated') >= 0 then attach = true else attach = false

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger 'ATTACH_EIP', uid, index, attach

            this.updateEIPList()

        removeIPfromList: (event) ->

            index = $($(event.target).parents('li').first().children()[1]).data().index

            $(event.target).parents('li').first().remove()

            $.each $("#property-eni-list").children(), (idx, val) ->

                $($(val).children()[1]).data('index', idx)

                $($(val).children()[1]).attr('data-index', idx)

            uid = $("#property-eni-attach-info").attr "component"

            this.trigger 'REMOVE_IP', uid, index

            this.updateEIPList()

        updateEIPList: (event) ->

            currentAvailableIPAry = []
            ipInuptListItem = $('#property-eni-list li')

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

    view = new ENIView()

    return view
