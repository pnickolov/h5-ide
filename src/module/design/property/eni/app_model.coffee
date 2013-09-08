#############################
#  View Mode for design/property/eni
#############################

define [ 'backbone', 'MC' ], () ->

    EniAppModel = Backbone.Model.extend {

        defaults :
          id: null

        init : ( eni_uid )->

          this.set 'id', eni_uid

          myEniComponent = MC.canvas_data.component[ eni_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          eni = $.extend true, {}, appData[ myEniComponent.resource.NetworkInterfaceId ]
          eni.name = myEniComponent.name

          if eni.status == "in-use"
            eni.isInUse = true

          eni.sourceDestCheck = if eni.sourceDestCheck is "true" then "enabled" else "disabled"

          for i in eni.privateIpAddressesSet.item
            i.primary = i.primary == "true"

          this.set eni

        getSGList : () ->

            # resourceId = this.get 'id'

            # # find stack by resource id
            # resourceCompObj = null
            # _.each MC.canvas_data.component, (compObj, uid) ->
            #     if compObj.resource.InstanceId is resourceId
            #         resourceCompObj = compObj
            #     null

            # sgAry = []
            # if resourceCompObj
            #     sgAry = resourceCompObj.resource.SecurityGroupId

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
