#############################
#  View Mode for design/property/instance
#############################

define [ '../base/model', 'keypair_model', 'constant', 'Design' ], ( PropertyModel, keypair_model, constant, Design ) ->

  LaunchConfigModel = PropertyModel.extend {

    initialize : ->
      me = this
      this.on 'EC2_KPDOWNLOAD_RETURN', ( result )->

        region_name = result.param[3]
        keypairname = result.param[4]

        # The user has closed the dialog
        # Do nothing
        if me.get("keyName") isnt keypairname
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

        keypair_model.download {sender:@}, username, session, Design.instance().region(), keypairname
        null


    init  : ( uid ) ->
      @lc = Design.instance().component( uid )

      data = @lc.toJSON()
      data.uid = uid
      data.isEditable = @isAppEdit
      @set data

      @set "displayAssociatePublicIp", not Design.instance().typeIsClassic()
      @set "monitorEnabled", @isMonitoringEnabled()
      @set "can_set_ebs", @lc.isEbsOptimizedEnabled()
      @getInstanceType()
      @getAmi()
      @getKeyPair()

      # if stack enable agent
      design = Design.instance()
      agentData = design.get('agent')
      @set "stackAgentEnable", agentData.enabled

      if @isApp
        @getAppLaunch( uid )
        @set 'keyName', @lc.connectionTargets( 'KeypairUsage' )[ 0 ].get("appId")
        return

      null

    getInstanceType : ( uid, data ) ->

      instance_type_list = MC.aws.ami.getInstanceType( @lc.getAmi() )

      if instance_type_list
        instanceType = @lc.get 'instanceType'

        view_instance_type = _.map instance_type_list, ( value )->
          main     : constant.INSTANCE_TYPE[value][0]
          ecu      : constant.INSTANCE_TYPE[value][1]
          core     : constant.INSTANCE_TYPE[value][2]
          mem      : constant.INSTANCE_TYPE[value][3]
          name     : value
          selected : instanceType is value

      @set "instance_type", view_instance_type
      null

    isMonitoringEnabled : ()->
      for p in @lc.parent().get("policies")
        if p.get("alarmData").metricName is "StatusCheckFailed"
          return false

      return true

    setEbsOptimized : ( value )->
      @lc.set 'ebsOptimized', value

    setCloudWatch : ( value ) ->
      @lc.set 'monitoring', value

    setUserData : ( value ) ->
      @lc.set 'userData', value

    setPublicIp : ( value )->
      @lc.set "publicIp", value

    setInstanceType  : ( value ) ->
      @lc.setInstanceType( value )
      @lc.isEbsOptimizedEnabled()

    getAmi : () ->
      ami_id = @get("imageId")
      ami    = @lc.getAmi()

      if not ami
        data = {
          name        : ami_id + " is not available."
          icon        : "ami-not-available.png"
          unavailable : true
        }
      else
        data = {
          name : ami.name
          icon : ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"
        }

      @set 'instance_ami', data
      null

    getKeyPair : ()->
      selectedKP = Design.instance().component(@get("uid")).connectionTargets("KeypairUsage")[0]

      @set "keypair", selectedKP.getKPList()
      null

    addKP : ( kp_name ) ->

      KpModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair )

      for kp in KpModel.allObjects()
        if kp.get("name") is kp_name
          return false

      kp = new KpModel( { name : kp_name } )
      kp.id

    deleteKP : ( kp_uid ) ->
      Design.instance().component( kp_uid ).remove()
      null

    setKP : ( kp_uid ) ->
      design  = Design.instance()
      instance = design.component( @get("uid") )
      design.component( kp_uid ).assignTo( instance )
      null

    isSGListReadOnly : ()->
      true

    getAppLaunch : ( uid ) ->
      lc_data   = MC.data.resource_list[Design.instance().region()][ @lc.get 'LaunchConfigurationARN' ]

      this.set "ebsOptimized", @lc.get("ebsOptimized") + ""
      this.set 'name', @lc.get 'name'
      this.set 'lc',   lc_data
      this.set 'uid',  uid
      null

    getStateData : () ->
      Design.instance().component( @get("uid") ).getStateData()

  }

  new LaunchConfigModel()
