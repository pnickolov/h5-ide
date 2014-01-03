
define [ "../ComplexResModel", "CanvasManager", "Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    type    : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
    defaults :
      x      : 2
      y      : 2
      width  : 9
      height : 9

      #servergroup
      serverGroupUid  : ''
      serverGroupName : ''
      count           : 1

      imageId      : ''
      tenancy      : 'default'
      ebsOptimized : false
      instanceType : "t1.micro"
      monitoring   : false
      userData     : ""

      cachedAmi : null

    constructor : ( attr, option )->
      # Create an embed eni
      if Design.instance().typeIsVpc()
        if not ( option and option.createEni is false )
          EniModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface )
          @setEmbedEni( new EniModel({}, { instance: this }) )

      ComplexResModel.call( this, attr, option )

      # Force to dedicated tenancy
      if vpc and not vpc.isDefaultTenancy()
        @setTenancy( "dedicated" )
      null

    initialize : ()->
      vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC()
      if vpc and not vpc.isDefaultTenancy()
        @setTenancy( "dedicated" )
      null

    setCount : ( count )->
      @set "count", count

      # Remove route to Embed Eni
      route = @getEmbedEni().connections('RTB_Route')[0]
      if route then route.remove()

      # Update my self and connected Eni
      @draw()
      for eni in @connectionTargets("EniAttachment")
        eni.draw()
      null

    isDefaultTenancy : ()->
      VpcModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC )
      vpc = VpcModel.allObjects()[0]
      if vpc and not vpc.isDefaultTenancy()
        return false
      else
        return @get("tenancy") isnt "dedicated"
      null

    getAmi : ()-> MC.data.dict_ami[@get("imageId")]
    getInstanceTypeConfig : ()->
      t = @get("instanceType").split(".")
      if t.length >= 2
        return MC.data.config[ Design.instance().region() ].instance_type[ t[0] ][ t[1] ]

      return null


    isEbsOptimizedEnabled : ()->
      EbsMap =
        "m1.large"   : true
        "m1.xlarge"  : true
        "m2.2xlarge" : true
        "m2.4xlarge" : true
        "m3.xlarge"  : true
        "m3.2xlarge" : true
        "c1.xlarge"  : true

      ami = @getAmi() || @get("cachedAmi")
      if ami and ami.rootDeviceType is "instance-store"
        return false

      return !!EbsMap[ @get("instanceType") ]

    setInstanceType : ( type )->

      # Ensure type is not t1.micro when using dedicated tenancy
      if type is "t1.micro" and not @isDefaultTenancy()
        type = "m1.small"

      @set("instanceType", type)
      if not @isEbsOptimizedEnabled()
        @set("ebsOptimized", false)

      # Eni's IP address count is limited by instanceType
      enis = @connectionTargets("EniAttachment")
      enis.push( @getEmbedEni() )
      for eni in enis
        eni.limitIpAddress()
      null

    setTenancy : ( tenancy )->
      @set "tenancy", tenancy

      if tenancy is "dedicated" and @get("instanceType") is "t1.micro"
        @setInstanceType "m1.small"
      null

    getInstanceTypeList : ()->

      instance_type_list = MC.aws.ami.getInstanceType( @getAmi() )

      if not instance_type_list
        return [{
          main     : ''
          ecu      : ''
          core     : ''
          mem      : ''
          name     : ''
          selected : false
          hide     : true
        }]

      tenancy      = @isDefaultTenancy()
      instanceType = @get("instanceType")

      return _.map instance_type_list, ( value )->
        main     : constant.INSTANCE_TYPE[value][0]
        ecu      : constant.INSTANCE_TYPE[value][1]
        core     : constant.INSTANCE_TYPE[value][2]
        mem      : constant.INSTANCE_TYPE[value][3]
        name     : value
        selected : instanceType is value
        hide     : not tenancy and value is "t1.micro"

    remove : ()->
      this.__mainEni.remove()

    setEmbedEni : ( eni )->
      this.__mainEni = eni
      null

    getEmbedEni : ()-> this.__mainEni

    iconUrl : ()->
      ami = @getAmi() || @get("cachedAmi")

      if not ami
        return "ide/ami/ami-not-available.png"
      else
        return "ide/ami/" + ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"

    draw : ( isCreate ) ->

      if isCreate

        # Call parent's createNode to do basic creation
        node = @createNode({
          image   : "ide/icon/instance-canvas.png"
          imageX  : 15
          imageY  : 9
          imageW  : 61
          imageH  : 62
          label   : @get "name"
          labelBg : true
          sg      : true
        })

        # Insert Volume / Eip / Port
        node.append(
          # Ami Icon
          Canvon.image( MC.IMG_URL + @iconUrl(), 30, 15, 39, 27 ),

          # Volume Image
          Canvon.image( MC.IMG_URL + 'ide/icon/instance-volume-attached-active.png' , 21, 44, 29, 24 ).attr({'class':'volume-image'}),
          # Volume Label
          Canvon.text( 35, 56, "0" ).attr({
            'class' : 'node-label volume-number'
            'value' : 0
          }),
          # Volume Hotspot
          Canvon.rectangle(21, 44, 29, 24).attr({
            'data-target-id' : @id
            'class'          : 'instance-volume'
            'fill'           : 'none'
          }),

          # Eip
          Canvon.image( "", 53, 47, 12, 14).attr({'class':'eip-status'}),

          # Child number
          Canvon.group().append(
            Canvon.rectangle(36, 1, 20, 16).attr({'class':'server-number-bg','rx':4,'ry':4}),
            Canvon.text(46, 13, "0").attr({'class':'node-label server-number'})
          ).attr({
            'class'   : 'server-number-group'
            "display" : "none"
          }),


          # left port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-instance-sg-left'
            'class'      : 'port port-blue port-instance-sg port-instance-sg-left'
            'transform'  : 'translate(5, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            'data-name'     : 'instance-sg' #for identify port
            'data-position' : 'left' #port position: for calc point of junction
            'data-type'     : 'sg'   #color of line
            'data-direction': 'in'   #direction
          }),

          # right port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-instance-sg-right'
            'class'      : 'port port-blue port-instance-sg port-instance-sg-right'
            'transform'  : 'translate(75, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            'data-name'     : 'instance-sg'
            'data-position' : 'right'
            'data-type'     : 'sg'
            'data-direction': 'out'
          })
        )

        if not Design.instance().typeIsClassic()
          # Show RTB/ENI Port in VPC Mode
          node.append(
            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-instance-attach'
              'class'      : 'port port-green port-instance-attach'
              'transform'  : 'translate(78, 45)' + MC.canvas.PORT_RIGHT_ROTATE
              'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
              'data-name'     : 'instance-attach'
              'data-position' : 'right'
              'data-type'     : 'attachment'
              'data-direction': 'out'
            })

            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-instance-rtb'
              'class'      : 'port port-blue port-instance-rtb'
              'transform'  : 'translate(42, -1)' + MC.canvas.PORT_UP_ROTATE
              'data-angle' : MC.canvas.PORT_UP_ANGLE
              'data-name'     : 'instance-rtb'
              'data-position' : 'top'
              'data-type'     : 'sg'
              'data-direction': 'in'
            })
          )

        if not Design.instance().modeIsStack()
          # instance-state
          node.append(
            Canvon.circle(68, 15, 5,{}).attr({
              'id'    : @id + '_instance-state'
              'class' : 'instance-state instance-state-unknown'
            })
          )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )

      # Update Server number
      numberGroup = node.children(".server-number-group")
      if @get("count") > 1
        CanvasManager.toggle node.children(".port-instance-rtb"), false
        CanvasManager.toggle numberGroup, true
        CanvasManager.update numberGroup.children("text"), @get("count")
      else
        CanvasManager.toggle node.children(".port-instance-rtb"), true
        CanvasManager.toggle numberGroup, false

      # update label
      MC.canvas.update( @id, "text", "hostname", @get("name") )

      # Update EIP
      eni = @getEmbedEni()
      if eni
        CanvasManager.update node.children(".eip-status"), @getEmbedEni().eipIconUrl(), "href"
      # TODO : Update Instance status

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

    deserialize : ( data, layout_data, resolve )->

      attr =
        id    : data.uid
        name  : data.name
        appId : data.resource.InstanceId

        #servergroup
        serverGroupUid  : data.serverGroupUid
        serverGroupName : data.serverGroupName
        count           : data.number

        imageId      : data.resource.ImageId
        tenancy      : data.resource.Placement.Tenancy
        ebsOptimized : data.resource.EbsOptimized
        instanceType : data.resource.InstanceType
        monitoring   : data.resource.Monitoring isnt "disabled"
        userData     : data.resource.UserData.Data

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

      if layout_data.osType and layout_data.architecture and layout_data.rootDeviceType
        attr.cachedAmi = {
          osType         : layout_data.osType
          architecture   : layout_data.architecture
          rootDeviceType : layout_data.rootDeviceType
        }

      if data.resource.SubnetId
        attr.parent = resolve( MC.extractID( data.resource.SubnetId ) )
      else
        attr.parent = resolve( MC.extractID( data.resource.Placement.AvailabilityZone ) )

      model = new Model( attr, { createEni : false } )

      # Add Keypair
      resolve( MC.extractID( data.resource.KeyName ) ).assignTo( model )
      null


  }

  Model
