
define [ "constant", "../ComplexResModel", "../ConnectionModel"  ], ( constant, ComplexResModel, ConnectionModel )->

  KeypairUsage = ConnectionModel.extend {
    type : "KeypairUsage"
    oneToMany : constant.RESTYPE.KP

    serialize : ( components )->
      kp = @getTarget( constant.RESTYPE.KP )
      otherTarget = @getOtherTarget( kp )

      components[ otherTarget.id ].resource.KeyName = kp.createRef( "KeyName" )
      null
  }



  KeypairModel = ComplexResModel.extend {
    type : constant.RESTYPE.KP

    defaults :
      fingerprint : ""

    isVisual : ()-> false

    remove : ()->
      # When a keypair is removed, make all usage to be DefaultKP
      defaultKp = KeypairModel.getDefaultKP()

      for i in @connectionTargets("KeypairUsage")
        new KeypairUsage( defaultKp, i )

      ComplexResModel.prototype.remove.call this
      null

    assignTo : ( target )-> new KeypairUsage( this, target )

    getKPList : ()->
      kps = []
      for kp in KeypairModel.allObjects()
        kps.push {
          id       : kp.id
          name     : kp.get("name")
          selected : kp is this
          using    : kp.connections("KeypairUsage").length > 1
        }

      _.sortBy kps, ( a, b )->
        if a.name is "DefaultKP" then return -1
        if b.name is "DefaultKP" then return 1
        if a.name > b.name then return 1
        if a.name is b.name then return 0
        if a.name < b.name then return -1


    serialize : ()->
      {
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            KeyFingerprint : @get("fingerprint")
            KeyName        : @get("appId") or @get("name")
      }

  }, {
    getDefaultKP : ()->
      _.find KeypairModel.allObjects(), ( obj )-> obj.get("name") is "DefaultKP"

    diffJson : ()-> # Disable diff for thie Model

    handleTypes : constant.RESTYPE.KP
    deserialize : ( data, layout_data, resolve )->
      new KeypairModel({
        id          : data.uid
        name        : data.name
        appId       : data.resource.KeyName
        fingerprint : data.resource.KeyFingerprint
      })
      null
  }

  KeypairModel
