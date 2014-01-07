#############################
#  View Mode for design/property/eni
#############################

define [ '../base/model', 'Design' ], ( PropertyModel, Design ) ->

    EniAppModel = PropertyModel.extend {

        init : ( uid )->

          group          = []
          myEniComponent = Design.instance().component( uid )
          appData        = MC.data.resource_list[ Design.instance().region() ]

          if @isGroupMode

            allEni = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface ).allObjects()

            for eni in allEni
              if eni.get 'serverGroupUid' is myEniComponent.get 'serverGroupUid'
                group.push eni

          else
            group.push myEniComponent


          formated_group = []
          for eni_comp in group
            eni = $.extend true, {}, appData[ eni_comp.get 'NetworkInterfaceId' ]

            for i in eni.privateIpAddressesSet.item
              i.primary = i.primary is true

            eni.id              = eni_comp.get 'NetworkInterfaceId'
            eni.name            = eni_comp.get 'name'
            eni.idx             = parseInt( eni_comp.get( 'name' ).split("-")[1], 10 )
            eni.sourceDestCheck = if eni.sourceDestCheck is "true" then "enabled" else "disabled"

            formated_group.push eni


          if @isGroupMode

            @set 'group',       _.sortBy formated_group, 'idx'
            @set 'readOnly',    true
            @set 'isGroupMode', true
            @set 'name',        myEniComponent.get 'name'
          else
            eni = formated_group[0]

            eni.readOnly    = true
            eni.isGroupMode = false
            eni.id          = uid
            @set eni

          null

        getSGList : () ->

            uid = this.get 'id'
            sgAry = Design.instance().component( uid ).get 'GroupSet'

            sgUIDAry = []
            _.each sgAry, (value) ->
                sgUID = value.GroupId.slice(1).split('.')[0]
                sgUIDAry.push sgUID
                null

            return sgUIDAry
    }

    new EniAppModel()
