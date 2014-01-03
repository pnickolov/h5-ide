
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    type : "EniAttachment"

    initialize : ()->

      # If Eni is attached to Ami, then hide sg line
      ami = @getTarget constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      eni = @getTarget constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

      for e in ami.connectionTargets( "EniAttachment" )
        if e is eni
          @setDestroyAfterInit()
          return

      @on "destroy", @tryReconnect
      null

    tryReconnect : ()->
      # When remove attachment, see if we need to connect sgline between eni and ami
      ami = @getTarget constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      eni = @getTarget constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      if ami and eni
        SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
        SgModel.tryDrawLine( ami, eni )

      null

    defaults :
      lineType : "attachment"

    portDefs :
      port1 :
        name : "instance-attach"
        type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

      port2 :
        name : "eni-attach"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

  }, {
    isConnectable : ( p1Comp, p2Comp )->
      # Instance and Eni should be in the same subnet or az
      p1Comp.parent() is p2Comp.parent()
  }

  C
