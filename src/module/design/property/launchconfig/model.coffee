#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'keypair_model', 'constant' ], ( PropertyModel, keypair_model, constant ) ->

  EbsMap =
    "m1.large"   : true
    "m1.xlarge"  : true
    "m2.2xlarge" : true
    "m2.4xlarge" : true
    "m3.xlarge"  : true
    "m3.2xlarge" : true
    "c1.xlarge"  : true
    #append
    "c3.2xlarge" : true
    "c3.4xlarge" : true
    "c3.xlarge"  : true
    "g2.2xlarge" : true
    "i2.2xlarge" : true
    "i2.4xlarge" : true
    "i2.xlarge"  : true


  LaunchConfigModel = PropertyModel.extend {

    initialize : ->
      me = this
      this.on 'EC2_KPDOWNLOAD_RETURN', ( result )->

        region_name = result.param[3]
        keypairname = result.param[4]

        curr_keypairname = me.get("lc")

        # The user has closed the dialog
        # Do nothing
        if curr_keypairname.KeyName isnt keypairname
            return

        ###
        # The EC2_KPDOWNLOAD_RETURN event won't fire when the result.is_error
        # is true. According to bugs in service models.
        ###

        me.trigger "KP_DOWNLOADED", result.resolved_data

        null


    downloadKP : ( keypairname ) ->
        username = $.cookie "usercode"
        session  = $.cookie "session_id"

        keypair_model.download {sender:@}, username, session, MC.canvas_data.region, keypairname
        null


    init  : ( uid ) ->

      @set 'uid', uid

      if @isApp
        @getAppLaunch( uid )
      else
        component = MC.canvas_data.component[ uid ]
        data = {
          uid      : uid
          userData : component.resource.UserData
          name     : component.name
          imageId  : component.resource.ImageId
        }
        @getCheckBox( uid, data )
        @getKeyPair( uid, data )
        @getInstanceType( uid, data )
        @getAssociatePublicIp( uid, data )
        @getAmi( uid, data )
        @getRootDevice()

        this.set data

      null

    setName  : ( name ) ->
      uid = this.get 'uid'
      MC.canvas_data.component[ uid ].name = name
      MC.canvas.update(uid,'text','lc_name', name)

      # update lc in extended asg
      asg_uid = MC.canvas_data.layout.component.node[ uid ].groupUId

      _.each MC.canvas_data.layout.component.group, ( group, id ) ->
        if group.originalId is asg_uid
          MC.canvas.update id, 'text', 'node-label', name
      null

    setInstanceType  : ( value ) ->
      uid = this.get 'uid'
      component = MC.canvas_data.component[ uid ]

      component.resource.InstanceType = value

      has_ebs = MC.aws.instance.canSetEbsOptimized component

      if not has_ebs
        component.resource.EbsOptimized = "false"

      has_ebs

    setEbsOptimized : ( value )->
      uid = this.get 'uid'
      MC.canvas_data.component[ uid ].resource.EbsOptimized = value
      null

    setCloudWatch : ( value ) ->
      uid = this.get 'uid'
      MC.canvas_data.component[ uid ].resource.InstanceMonitoring = value
      null

    setUserData : ( value ) ->

      uid = this.get 'uid'
      MC.canvas_data.component[ uid ].resource.UserData = value
      null

    unAssignSGToComp : (sg_uid) ->

      lcUID = this.get 'uid'

      originSGIdAry = MC.canvas_data.component[lcUID].resource.SecurityGroups

      currentSGId = '@' + sg_uid + '.resource.GroupId'

      originSGIdAry = _.filter originSGIdAry, (value) ->
        value isnt currentSGId

      MC.canvas_data.component[lcUID].resource.SecurityGroups = originSGIdAry


      null

    assignSGToComp : (sg_uid) ->

      instanceUID = this.get 'uid'

      originSGIdAry = MC.canvas_data.component[instanceUID].resource.SecurityGroups

      currentSGId = '@' + sg_uid + '.resource.GroupId'


      if !Boolean(currentSGId in originSGIdAry)
        originSGIdAry.push currentSGId

      MC.canvas_data.component[instanceUID].resource.SecurityGroups = originSGIdAry

      null

    getCheckBox : ( uid, checkbox ) ->

      resource = MC.canvas_data.component[ uid ].resource

      checkbox.ebsOptimized = "" + resource.EbsOptimized is 'true'
      checkbox.monitoring   = "" + resource.InstanceMonitoring is 'true'

      watches = []
      asg = null
      monitorEnabled = true
      for id, comp of MC.canvas_data.component
        if comp.type is constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch
          watches.push comp
        else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
          if comp.resource.LaunchConfigurationName.indexOf( uid ) != -1
            asg = comp

      for watch in watches
        if watch.resource.MetricName.indexOf("StatusCheckFailed") != -1
          for d in watch.resource.Dimensions
            if d.value and d.value.indexOf( asg.uid ) != -1
              monitorEnabled = false
              break

          if not monitorEnabled
            break

      checkbox.monitorEnabled = monitorEnabled

      null

    getAmi : ( uid, data ) ->

      ami_id = MC.canvas_data.component[ uid ].resource.ImageId
      ami    = MC.data.dict_ami[ami_id]

      if not ami
        data.instance_ami = {
          name        : ami_id + " is not available."
          icon        : "ami-not-available.png"
          unavailable : true
        }
      else
        data.instance_ami = {
          name : ami.name
          icon : "#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"
        }
      null

    getKeyPair : ( uid, data )->

      keypair_id = MC.extractID MC.canvas_data.component[ uid ].resource.KeyName
      data.keypair = MC.aws.kp.getList( keypair_id )

      null

    addKP : ( kp_name ) ->

      result = MC.aws.kp.add kp_name

      if not result
        return result

      uid = @get 'uid'
      MC.canvas_data.component[ uid ].resource.KeyName = "@#{result}.resource.KeyName"
      true

    deleteKP : ( key_name ) ->

      MC.aws.kp.del key_name

      # Update data of this model
      for kp, idx in @attributes.keypair
        if kp.name is key_name
          @attributes.keypair.splice idx, 1
          break

      null

    setKP : ( key_name ) ->

      uid = this.get 'uid'
      MC.canvas_data.component[ uid ].resource.KeyName = "@#{MC.canvas_property.kp_list[key_name]}.resource.KeyName"

      null

    setPublicIp : ( value ) ->

      uid = this.get 'uid'

      MC.canvas_data.component[ uid ].resource.AssociatePublicIpAddress = value

      null

    getAssociatePublicIp: ( uid, data ) ->
      resource = MC.canvas_data.component[ uid ].resource

      vpcId = MC.aws.vpc.getVPCUID()
      isDefaultVpc = MC.aws.aws.checkDefaultVPC()

      if vpcId and not isDefaultVpc
        data.displayAssociatePublicIp = true
        data.AssociatePublicIpAddress = resource.AssociatePublicIpAddress

      null

    getInstanceType : ( uid, data ) ->

      amiId = MC.canvas_data.component[uid].resource.ImageId

      ami_info = MC.data.dict_ami[amiId]

      #MC.canvas_data.layout.component.node[ uid ]

      current_instance_type = MC.canvas_data.component[ uid ].resource.InstanceType

      instanceTypeAry = MC.aws.ami.getInstanceType(ami_info)
      view_instance_type = _.map instanceTypeAry, ( value )->

        main     : constant.INSTANCE_TYPE[value][0]
        ecu      : constant.INSTANCE_TYPE[value][1]
        core     : constant.INSTANCE_TYPE[value][2]
        mem      : constant.INSTANCE_TYPE[value][3]
        name     : value
        selected : current_instance_type is value

      data.instance_type = view_instance_type
      data.can_set_ebs   = EbsMap.hasOwnProperty current_instance_type
      null

    isSGListReadOnly : ()->
      true

    getSGList : () ->

      uid = this.get 'uid'
      sgAry = MC.canvas_data.component[uid].resource.SecurityGroups

      sgUIDAry = []
      _.each sgAry, (value) ->
        sgUID = value.slice(1).split('.')[0]
        sgUIDAry.push sgUID
        null

      return sgUIDAry

    getAppLaunch : ( uid ) ->

      component = MC.canvas_data.component[uid]
      lc_data   = MC.data.resource_list[MC.canvas_data.region][ component.resource.LaunchConfigurationARN ]

      this.set 'name', component.name
      this.set 'lc',   lc_data
      this.set 'uid',  uid
      null

    #### root device ####
    getRootDevice : () ->

      uid         = this.get 'uid'
      volume_detail = null
      root_device = MC.aws.ami.getRootDevice MC.canvas_data.component[ uid ].resource.ImageId
      device_list = MC.canvas_data.component[ uid ].resource.BlockDeviceMapping
      for value, key in device_list
        if root_device.DeviceName is value.DeviceName
          #root device
          volume_detail =
            isLC        : false
            isWin       : value.DeviceName != '/'
            isStandard  : value.Ebs.VolumeType is 'standard'
            iops        : value.Ebs.Iops
            volume_size : value.Ebs.VolumeSize
            snapshot_id : value.Ebs.SnapshotId
            name        : value.DeviceName


      this.set 'volume_detail', volume_detail
      
      @getMinVolumeSize()

      null


    getMinVolumeSize : () ->

      volume = @getVolume()
      uid    = this.get 'uid'
      if !volume
        uid = this.get 'uid'
        console.error "[setVolumeSize]not found rootDevice of uid: " + uid
        return null

      ami = MC.data.dict_ami[ MC.canvas_data.component[uid].resource.ImageId ]
      if ami and ami.rootDeviceName and ami.blockDeviceMapping[ami.rootDeviceName]
        minVolSize = ami.blockDeviceMapping[ami.rootDeviceName].volumeSize
        this.set "min_volume_size", Number(minVolSize)
      else
        this.set "min_volume_size", 1
        console.warn "setVolumeSize(): can not found root device of AMI " + ami.imageId
      null

    getVolume : () ->

      uid         = this.get 'uid'
      volume      = null
      root_device = MC.aws.ami.getRootDevice MC.canvas_data.component[ uid ].resource.ImageId
      device_list = MC.canvas_data.component[ uid ].resource.BlockDeviceMapping
      for value, key in device_list
        if root_device.DeviceName is value.DeviceName
          #root device
          volume = value
      volume



    setVolumeSize : ( value ) ->

      volume = @getVolume()
      uid    = this.get 'uid'
      if !volume
        uid = this.get 'uid'
        console.error "[setVolumeSize]not found rootDevice of uid: " + uid
        return null

      ami = MC.data.dict_ami[ MC.canvas_data.component[uid].resource.ImageId ]
      if ami and ami.rootDeviceName and ami.blockDeviceMapping[ami.rootDeviceName]
        minVolSize = ami.blockDeviceMapping[ami.rootDeviceName].volumeSize
        if value >= minVolSize
          volume.Ebs.VolumeSize = value
        #else
          #notification 'warning', sprintf lang.ide.PROP_MSG_WARN_ROOT_DEVICE_SIZE_ERROR, value, volume.Ebs.SnapshotId, minVolSize
      else
        console.warn "setVolumeSize(): can not found root device of AMI " + ami.imageId
      null

    setVolumeTypeStandard : () ->

      volume = @getVolume()
      if !volume
        uid = this.get 'uid'
        console.error "[setVolumeTypeStandard]not found rootDevice of uid: " + uid
        return null

      volume.Ebs.VolumeType = 'standard'
      delete volume.Ebs.Iops
      null

    setVolumeTypeIops : ( value ) ->

      volume = @getVolume()
      if !volume
        uid = this.get 'uid'
        console.error "[setVolumeTypeIops]not found rootDevice of uid: " + uid
        return null

      volume.Ebs.VolumeType = 'io1'
      volume.Ebs.Iops       = value
      null


    setVolumeIops : ( value )->

      volume = @getVolume()
      if !volume
        uid = this.get 'uid'
        console.error "[setVolumeIops]not found rootDevice of uid: " + uid
        return null

      volume.Ebs.VolumeType = "io1"
      volume.Ebs.Iops       = value
      null

  }

  new LaunchConfigModel()
