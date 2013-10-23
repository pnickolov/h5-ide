#############################
#  View(UI logic) for design/property/instacne
#############################

define [ '../base/view',
         'text!./template/app_edit.html', 'i18n!nls/lang.js', 'UI.zeroclipboard','text!./template/ip_list.html'  ], ( PropertyView, template, lang, zeroclipboard, ip_list_template ) ->

    template = Handlebars.compile template
    ip_list_template = Handlebars.compile ip_list_template
    InstanceView = PropertyView.extend {

        events : {}

        render : ( ) ->

            # Render
            #@$el.html( template() )
            @$el.html template @model.attributes
            @refreshIPList()
            # Return title of property
            return "Instance App Edit"

        openAmiPanel : ( event ) ->
            this.trigger "OPEN_AMI", $( event.target ).data("uid")
            false

        changeIPAddBtnState : () ->

            disabledBtn = false
            instanceUID = this.model.get 'get_uid'

            maxIPNum = MC.aws.eni.getENIMaxIPNum(instanceUID)
            currentENIComp = MC.aws.eni.getInstanceDefaultENI(instanceUID)
            if !currentENIComp
                disabledBtn = true
                return

            currentIPNum = currentENIComp.resource.PrivateIpAddressSet.length
            if maxIPNum is currentIPNum
                disabledBtn = true

            instanceType = MC.canvas_data.component[instanceUID].resource.InstanceType
            if disabledBtn
                tooltipStr = sprintf(lang.ide.PROP_MSG_WARN_ENI_IP_EXTEND, instanceType, maxIPNum)
                $('#instance-ip-add').addClass('disabled').attr('data-tooltip', tooltipStr).data('tooltip', tooltipStr)
            else
                $('#instance-ip-add').removeClass('disabled').attr('data-tooltip', 'Add IP Address').data('tooltip', 'Add IP Address')

            null

        refreshIPList : ( event ) ->
            @model.getEni()
            $( '#property-network-list' ).html( ip_list_template( @model.attributes ) )
            this.changeIPAddBtnState()
    }

    new InstanceView()
