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
      @lc = Design.instance().component( uid )

      data = @lc.toJSON()
      data.uid = uid
      @set data

      @set "displayAssociatePublicIp", Design.instance().typeIsVpc()
      @set "monitorEnabled", @isMonitoringEnabled()
      @getInstanceType()

      if @isApp
        @getAppLaunch( uid )
        return

      null

    getInstanceType : ( uid, data ) ->
      amiId = @lc.get 'imageId'

      ami_info = MC.data.dict_ami[amiId]

      current_instance_type = @lc.get 'instanceType'

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

    isMonitoringEnabled : ()->
      monitorEnabled = true

      WatchModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch )

      asg = @lc.getFromStorage( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group ).first()

      for watch in WatchModel.allObjects()
        if watch.get( 'MetricName' ).indexOf("StatusCheckFailed") != -1
          for d in watch.get( 'Dimensions' )
            if d.value and d.value.indexOf( asg.id ) != -1
              monitorEnabled = false
              break

          if not monitorEnabled
            break

      monitorEnabled

    setEbsOptimized : ( value )->
      @lc.set 'ebsOptimized', value

    setCloudWatch : ( value ) ->
      @lc.set 'instanceMonitoring', value

    setUserData : ( value ) ->
      @lc.set 'userData', value

    setPublicIp : ( value )->
      @lc.set "publicIp", value




    setInstanceType  : ( value ) ->

      @lc.set 'InstanceType', value

      has_ebs = EbsMap.hasOwnProperty value
      if not has_ebs
        component.resource.EbsOptimized = "false"

      has_ebs

    getAmi : ( uid, data ) ->

      ami_id = @lc.get 'ImageId'
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

      keypairInuse = @lc.getFromStorage( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair ).first()

      #data.keypair = MC.aws.kp.getList( keypair_id )

      kpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )

      allKp = kpModel and kpModel.allObjects() or []

      kps = []

      for kp in allKp
        name = kp.get 'name'
        kp_uid = kp.id
        inUse = kp.getFromStorage().length > 0

        kp = {
          name     : name
          using    : inUse
          selected : kp_uid is keypairInuse.id
        }

        if name is "DefaultKP"
          kps.unshift kp
        else
          kps.push kp

      data.keypair = kps

      null

    addKP : ( kp_name ) ->

      result = MC.aws.kp.add kp_name

      kpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )
      kp = new kpModel { id: MC.guid(), name:kp_name }

      @lc.associate kp

      true

    deleteKP : ( key_name ) ->

      kpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )

      allKp = kpModel and kpModel.allObjects() or []

      for kp in allKp
        if kp.get 'name' is key_name
          kp.remove()
          break

      null

    setKP : ( key_name ) ->

      uid = this.get 'uid'
      kpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )

      allKp = kpModel and kpModel.allObjects() or []

      for kp in allKp
        if kp.get( 'name' ) is key_name
          @lc.disassociate constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
          @lc.associate kp
          break

      #@lc.set 'KeyName', "@#{MC.canvas_property.kp_list[key_name]}.resource.KeyName"

      null

    isSGListReadOnly : ()->
      true

    getAppLaunch : ( uid ) ->
      lc_data   = MC.data.resource_list[MC.canvas_data.region][ @lc.get 'LaunchConfigurationARN' ]

      this.set 'name', @lc.get 'name'
      this.set 'lc',   lc_data
      this.set 'uid',  uid
      null

  }

  new LaunchConfigModel()
