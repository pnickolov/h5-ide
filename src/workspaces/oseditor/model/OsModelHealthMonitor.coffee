
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.OSHM
    newNameTmpl : "health-monitor"

    defaults: ()->
      type            : 'PING'
      delay           : 30
      timeout         : 30
      maxRetries      : 3
      urlPath         : '/index.html'
      expectedCodes   : '200-299'

    get: ( attr ) ->
      if attr in [ 'urlPath', 'expectedCodes' ] and @attributes.type not in [ 'HTTP', 'HTTPS' ]
        undefined
      else
        @attributes[attr]

    serialize : ()->
      component =
        name : @get 'name'
        type : @type
        uid  : @id
        resource :
          id   : @get 'appId'
          name : @get 'name'
          type            : @get 'type'
          delay           : Number(@get('delay'))
          timeout         : Number(@get('timeout'))
          max_retries     : Number(@get('maxRetries'))
          url_path: @get( 'urlPath' ) or ""
          expected_codes: @get( 'expectedCodes' ) or ""

      # if @get( 'type' ) in [ 'HTTP', 'HTTPS' ]
      #   _.extend component.resource, {
          # url_path: @get 'urlPath'
          # expected_codes: @get 'expectedCodes'
      #   }

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSHM

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id            : data.uid
        name          : data.resource.name
        appId         : data.resource.id

        type          : data.resource.type
        delay         : Number(data.resource.delay)
        timeout       : Number(data.resource.timeout)
        maxRetries    : Number(data.resource.max_retries)
        urlPath       : data.resource.url_path
        expectedCodes : data.resource.expected_codes

      })
      return
  }

  Model
