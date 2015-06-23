
define [ "constant", "ComplexResModel", "GroupModel", "Design", "./connection/TagUsage"  ], ( constant, ComplexResModel, GroupModel, Design, TagUsage )->


  TagItem = ComplexResModel.extend {
    type : "TagItem"

    serialize: ->
      {
        Key   : @get 'key'
        Value : @get 'value'
        ResourceIds: @genResourceIds()
      }

    genResourceIds: ->
      _.map @connectionTargets(), (resource) ->
        resource.createRef constant.AWS_RESOURCE_KEY[ resource.type ]



  }, {
    deserialize: ( data, layout_data, resolve ) ->
      tagItem = new TagItem( key: data.Key, value: data.Value )

      for id in data.ResourceIds
        resource = resolve MC.extractID id
        continue unless resource

        new TagUsage resource, tagItem

      tagItem
  }


  TagModel = GroupModel.extend {
    type: constant.RESTYPE.TAG

    serialize : ->
      component :
        name : @get("name")
        type : @type
        uid  : @id
        resource : _.invoke @children(), 'serialize'
                   # _.map @children(), ( tagItem ) -> tagItem.serialize()

    addTag: (tagKey, tagValue, resource) ->
      tagItem = _.findWhere @children(), { key: tagKey, value: tagValue }
      tagItem = new TagItem( { key: tagKey, value: tagValue, __parent: @ } ) unless tagItem

      new TagUsage resource, tagItem

    removeTag: ( tagItem, resource ) ->
      (new TagUsage resource, tagItem).remove()

  }, {

    handleTypes : [ constant.RESTYPE.TAG ]
    deserialize : ( data, layout_data, resolve )->
      attr = {
        id    : data.uid
        name  : data.name
      }

      tagModel = new @( attr )

      for r in data.resource
        item = TagItem.deserialize r, null, resolve
        tagModel.addChild item

      null
  }

  TagModel
