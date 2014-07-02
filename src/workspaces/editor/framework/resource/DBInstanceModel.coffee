
define [ "../ComplexResModel", "Design", "constant", 'i18n!/nls/lang.js', 'CloudResources' ], ( ComplexResModel, Design, constant, lang, CloudResources )->

  ComplexResModel.extend {

    defaults : () ->
      x        : 0
      y        : 0
      width    : 9
      height   : 9

      imageId      : ""
      ebsOptimized : false
      instanceType : "m1.small"
      monitoring   : false
      userData     : ""
      publicIp     : false
      state        : null

    type : constant.RESTYPE.DBINSTANCE
    newNameTmpl : "db-instance-"

    constructor : ( attr, option ) ->
      ComplexResModel.call( this, attr, option )


    initialize : ( attr, option )->
      @draw true

      null




    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CustomerGatewayId : @get("appId")
          BgpAsn            : @get("bgpAsn")
          Type              : "ipsec.1"
          IpAddress         : @get("ip")

      { component : component, layout : @generateLayout() }


  }, {

    handleTypes: constant.RESTYPE.DBINSTANCE

    deserialize : ( data, layout_data, resolve )->
      new Model({

        id     : data.uid
        name   : data.name

        #x : layout_data.coordinate[0]
        #y : layout_data.coordinate[1]
      })
  }


