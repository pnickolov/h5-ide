#############################
#  View Mode for design/property/stack
#############################

define ['../base/model', 'constant', "Design" ], ( PropertyModel, constant, Design ) ->

  StackModel = PropertyModel.extend {

    init : () ->

      design = Design.instance()

      if not design.get("name")
        return null

      agentData = design.get('agent')

      @set {
        name      : design.get("name").replace(/\s+/g, '')
        id        : design.get("id")
        usage     : design.get("usage")
        description: design.get('description')
        type      : "EC2 VPC"
        region    : constant.REGION_SHORT_LABEL[ design.region() ]
        isApp     : @isApp
        isAppEdit : @isAppEdit
        isStack   : @isStack
        isImport  : design.modeIsAppView()
        isResDiff : design.get 'resource_diff'
        opsEnable : agentData.enabled
      }

      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()
      if vpc then @set "vpcid", vpc.get("appId")

      @getNetworkACL()

      if @isStack
        @set 'isStack', true


      @set Design.instance().getCost()
      @set "currency", Design.instance().getCurrency()
      null

    createAcl : ()->
      ACLModel = Design.modelClassForType( constant.RESTYPE.ACL )
      (new ACLModel()).id

    getNetworkACL : ()->

      ACLModel = Design.modelClassForType( constant.RESTYPE.ACL )

      networkAcls = []
      defaultACL  = null

      _.each ACLModel.allObjects(), ( acl )=>

        deletable = true
        if @isApp
          deletable = false
        else if acl.isDefault()
          deletable = false
        else if @isAppEdit
          # If the acl has appId, deletable is false
          deletable = not acl.get("appId")

        aclObj = {
          uid         : acl.id
          name        : acl.get("name")
          rule        : acl.getRuleCount()
          association : acl.getAssoCount()
          deletable   : deletable
        }

        if acl.isDefault()
          defaultACL = aclObj
        else
          networkAcls.splice( _.sortedIndex( networkAcls, aclObj, "name" ), 0, aclObj )

        null

      if defaultACL
        networkAcls.splice( 0, 0, defaultACL )

      @set "networkAcls", networkAcls
      null

    removeAcl : ( acl_uid )->
      Design.instance().component( acl_uid ).remove()
      @getNetworkACL()
      null

    updateStackName : ( name )->
      @set "name", name
      Design.instance().set("name", name)
      return

    updateDescription : ( description )->
      @set "description", description
      Design.instance().set('description', description)
      return

    setMarathon: (marathonOn) ->
      Design.modelClassForType( constant.RESTYPE.MESOSMASTER ).setMarathon marathonOn

    getMarathon: ->
      Design.modelClassForType( constant.RESTYPE.MESOSMASTER ).getMarathon()

  }

  new StackModel()
