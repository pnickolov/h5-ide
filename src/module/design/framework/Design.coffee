define [ "constant" ], ( constant ) ->

  ###
    -------------------------------
     Design is the main controller of the framework. It handles the input / ouput of the Application ( a.k.a the DesignCanvas ).
     The input and ouput is the same : the JSON data.
    -------------------------------


    ++ Class Method ++

    # instance() : Design
        description : returns the currently used Design object.


    ++ Object Method ++

    # getComponent( uid ) : ResourceModel
        description : returns a resource model of uid

    # getAZ( azName ) : AzModel
        description : returns a AzModel, if the azModel doesn't exist, it will be created.

    # createConnection( p1U, p1N, p2U, p2N ) : ConnectionModel
        description : returns a ConnectionModel for the connection.

    # serialize() : Object
        description : returns a Plain JS Object that is indentical to JSON data.

    # serializeLayout() : Object
        description : returns a Plain JS Object that is indentical to Layout data.

  ###

  design_instance = null


  Design = ( json_data, layout_data, options )->

    @__componentMap = {}
    @__classCache   = {}

    this.__type = options.type
    this.__mode = options.mode

    @use()
    @

  Design.TYPE = {
    Classic    : "Classic"
    Vpc        : "Vpc"
    DefaultVpc : "DefaultVpc"
  }
  Design.MODE = {
    Stack   : "Stack"
    App     : "App"
    AppEdit : "AppEdit"
  }

  ### Private Interface ###
  Design.__modelClassMap = {}
  Design.registerModelClass = ( type, modelClass )->
    @__modelClassMap[ type ] = modelClass
    null

  Design.modelClassForType = ( type )-> @__modelClassMap[ type ]

  Design.prototype.classCacheForCid = ( cid )->
    if @__classCache[ cid ]
      return @__classCache[ cid ]

    cache = @__classCache[ cid ] = []
    return cache

  Design.prototype.cacheComponent = ( id, comp )->
    if not comp
      delete @__componentMap[ id ]
    else
      @__componentMap[ id ] = comp
  ### Private Interface End ###


  Design.instance = ()-> design_instance


  Design.prototype.mode          = ()-> this.__mode
  Design.prototype.modeIsStack   = ()-> this.__mode == Design.MODE.Stack
  Design.prototype.modeIsApp     = ()-> this.__mode == Design.MODE.App
  Design.prototype.modeIsAppEdit = ()-> this.__mode == Design.MODE.AppEdit

  Design.prototype.type             = ()-> this.__type
  Design.prototype.typeIsClassic    = ()-> this.__type == Design.TYPE.Classic
  Design.prototype.typeIsDefaultVpc = ()-> this.__type == Design.TYPE.DefaultVpc
  Design.prototype.typeIsVpc        = ()-> this.__type == Design.TYPE.Vpc


  Design.prototype.use = ()->
    design_instance = this
    null

  Design.prototype.getComponent = ( uid )->
    @__componentMap[ uid ]


  Design.prototype.getAZ = ( azName )->
    AzModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone )

    allAzs = AzModel.allObjects()
    for az in allAzs
      if az.get("name") is azName
        return az

    az = new AzModel({name:azName})
    az

  Design.prototype.serialize = ()->


  Design.prototype.serializeLayout = ()->


  Design.prototype.createConnection = ( p1Uid, port1, p2Uid, port2 )->

  Design
