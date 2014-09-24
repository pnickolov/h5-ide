

define ["ApiRequest", "CloudResources", "constant", "backbone"], ( ApiRequest, CloudResources, constant )->

  ###
    Dashboard Model
  ###
  Backbone.Model.extend {

    initialize : ()->

    ### Cloud Resources ###
    fetchAwsResources : ( region )->
      if not region
        CloudResources( constant.RESTYPE.INSTANCE ).fetch()
        CloudResources( constant.RESTYPE.EIP ).fetch()
        CloudResources( constant.RESTYPE.VOL ).fetch()
        CloudResources( constant.RESTYPE.ELB ).fetch()
        CloudResources( constant.RESTYPE.VPN ).fetch()
        _.each constant.REGION_KEYS, (e)->
          CloudResources( constant.RESTYPE.DBINSTANCE, e).fetch()
        return

      CloudResources( constant.RESTYPE.SUBSCRIPTION, region ).fetch()
      CloudResources( constant.RESTYPE.VPC ).fetch()
      CloudResources( constant.RESTYPE.DHCP, region ).fetch()
      CloudResources( constant.RESTYPE.ASG ).fetch()
      CloudResources( constant.RESTYPE.CW ).fetch()
      CloudResources( constant.RESTYPE.ENI, region ).fetch()
      CloudResources( constant.RESTYPE.CGW, region ).fetch()
      CloudResources( constant.RESTYPE.VGW, region ).fetch()
      return
  }
