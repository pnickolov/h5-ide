#############################
#  View Mode for design/property/eni
#############################

define [ '../base/model' ], ( PropertyModel ) ->

    EniAppModel = PropertyModel.extend {

        init : ( uid )->

          group          = []
          myEniComponent = Design.instance().component( uid )
          appData        = MC.data.resource_list[ MC.canvas_data.region ]

          if @isGroupMode

            for uid, component of MC.canvas_data.component
              if component.serverGroupUid is myEniComponent.serverGroupUid
                group.push component

          else
            group.push myEniComponent


          formated_group = []
          for eni_comp in group
            eni = $.extend true, {}, appData[ eni_comp.resource.NetworkInterfaceId ]

            for i in eni.privateIpAddressesSet.item
              i.primary = i.primary is true

            eni.id              = eni_comp.resource.NetworkInterfaceId
            eni.name            = eni_comp.name
            eni.idx             = parseInt( eni_comp.name.split("-")[1], 10 )
            eni.sourceDestCheck = if eni.sourceDestCheck is "true" then "enabled" else "disabled"

            formated_group.push eni


          if @isGroupMode

            @set 'group',       _.sortBy formated_group, 'idx'
            @set 'readOnly',    true
            @set 'isGroupMode', true
            @set 'name',        myEniComponent.name
          else
            eni = formated_group[0]

            eni.readOnly    = true
            eni.isGroupMode = false
            eni.id          = uid
            @set eni

          null

        getSGList : () ->

            uid = this.get 'id'
            sgAry = MC.canvas_data.component[uid].resource.GroupSet

            sgUIDAry = []
            _.each sgAry, (value) ->
                sgUID = value.GroupId.slice(1).split('.')[0]
                sgUIDAry.push sgUID
                null

            return sgUIDAry
    }

    new EniAppModel()
