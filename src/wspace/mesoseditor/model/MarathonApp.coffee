
define [ "ComplexResModel", "constant", "./MarathonDepIn", "i18n!/nls/lang.js" ], ( ComplexResModel, constant, MarathonDepIn, lang )->

  COLORSET = ["#1abc9c","#2ecc71","#3498db","#9b59b6","#34495e","#16a085","#27ae60","#2980b9","#8e44ad","#2c3e50","#f1c40f","#e67e22","#e74c3c","#f39c12","#d35400","#c0392b","#7f8c8d","#95a5a6"]

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
      healthChecks: [{
          path: "/api/health",
          portIndex: 0,
          protocol: "HTTP",
          gracePeriodSeconds: 300,
          intervalSeconds: 60,
          timeoutSeconds: 20,
          maxConsecutiveFailures: 3
        }]
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
      component =
        uid      : @id
        type     : @type
        toplevel : !@parent()
        color    : @get("color")
        resource :
          id : @get("name")
          container: _.extend { type: 'DOCKER' }, @get("container")

      for key in ['cpus', 'mem', 'instances', 'cmd', 'args', 'env', 'ports', 'executor', 'uris', 'constraints', 'healthChecks', 'upgradeStrategy']
        if @get(key)
          component.resource[key] = @get(key)

      { component : component, layout : @generateLayout() }

    isReparentable : ( newParent )-> !(newParent and _.find( newParent.children(), (r)-> r.type is constant.RESTYPE.MRTHGROUP ))

  }, {

    handleTypes : constant.RESTYPE.MRTHAPP

    deserialize : ( data, layout_data, resolve )->
      console.log data
      attributes ={
        id     : data.uid
        name   : data.resource.id
        parent : if layout_data.groupUId then resolve( layout_data.groupUId ) else null

        container: data.resource.containers
        color : data.color

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      }

      for key in ['cpus', 'mem', 'instances', 'cmd', 'args', 'env', 'ports', 'executor', 'uris', 'constraints', 'healthChecks', 'upgradeStrategy']
      if data[key]
        attributes[key] = data[key]

      new Model(attributes)

    postDeserialize : ( data, layout_data )->
      for dep in data.resource.dependencies || []
        new MarathonDepIn( Design.instance().component(data.uid), dep )

      return
  }

  Model

