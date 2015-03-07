
define [ "ComplexResModel", "constant", "./MarathonDepIn", "i18n!/nls/lang.js" ], ( ComplexResModel, constant, MarathonDepIn, lang )->

  COLORSET = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#16a085","#27ae60","#2980b9","#8e44ad","#2c3e50","#f1c40f","#e67e22","#e74c3c","#f39c12","#d35400","#c0392b","#7f8c8d","#95a5a6"]

  doRemoveEmptyArray = ( obj ) ->
      if !_.isObject obj then return
      _.each obj, ( value, key ) ->
        if _.isArray( value )
          unless value.length
            delete obj[ key ]
        else
          doRemoveEmptyArray value

  removeEmptyArray = ( obj ) ->
    cloneData = $.extend true, {}, obj
    doRemoveEmptyArray cloneData
    cloneData


  Model = ComplexResModel.extend {

    type : constant.RESTYPE.MRTHAPP
    newNameTmpl : "app"

    defaults :()->
      color : COLORSET[ Math.round(Math.random()*COLORSET.length) ]
      container: { docker: {}, volumes: [] }
      cpus: 1.5
      mem: 256
      instances: 3
      constraints: []
      version: ''
      upgradeStrategy: {
        minimumHealthCapacity: 0.5,
        maximumOverCapacity: 0.2
      }

    path : ()->
      path = []
      t = @
      while t
        path.unshift( t.get("name") )
        t = t.parent()
      ("/" + path.join("/")).replace(/\/+/g,"/")

    serialize : ()->
      console.log @toJSON()
      resource = {
        id : @get("name")
        container: @getContainerJson()
      }
      for key in ['cpus', 'mem', 'instances', 'cmd', 'args', 'env', 'ports', 'executor', 'uris', 'constraints', 'healthChecks', 'upgradeStrategy']
        if @get(key)
          resource[key] = @get(key)

      component =
        uid      : @id
        type     : @type
        toplevel : !@parent()
        color    : @get("color")
        version  : @get("version")
        resource : removeEmptyArray resource

      { component : component, layout : @generateLayout() }

    getContainerJson: ->
      _.extend { type: 'DOCKER' }, @container()

    container: ->
      c = @get( 'container' )
      c.docker.image = @get 'image'
      c

    isReparentable : ( newParent )-> !(newParent and _.find( newParent.children(), (r)-> r.type is constant.RESTYPE.MRTHGROUP ))

  }, {

    handleTypes : constant.RESTYPE.MRTHAPP

    deserialize : ( data, layout_data, resolve )->
      console.log data
      attributes = {
        id     : data.uid
        name   : data.resource.id
        parent : if layout_data.groupUId then resolve( layout_data.groupUId ) else null

        container : data.resource.container
        image     : data.resource.container.docker.image
        color     : data.color
        version   : data.version or ''

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      }

      for key in ['cpus', 'mem', 'instances', 'cmd', 'args', 'env', 'ports', 'executor', 'uris', 'constraints', 'healthChecks', 'upgradeStrategy']
        if data.resource[key]
          attributes[key] = data.resource[key]

      new Model(attributes)

    postDeserialize : ( data, layout_data )->
      for dep in data.resource.dependencies || []
        new MarathonDepIn( Design.instance().component(data.uid), dep )

      return
  }

  Model

