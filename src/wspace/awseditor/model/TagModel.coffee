
define [ "constant", "ComplexResModel", "GroupModel", "Design", "./connection/TagUsage"  ], ( constant, ComplexResModel, GroupModel, Design, TagUsage )->

  TagItem = ComplexResModel.extend {
    type : "TagItem"

    initialize: ( attributes ) ->
      if attributes and attributes.inherit is undefined
        @unset 'inherit'

    serialize: ->
      _.extend {
        Key   : @get 'key'
        Value : @get 'value'
        ResourceIds: @genResourceIds()
      }, if @has('inherit') then { PropagateAtLaunch: @get('inherit') } else null

    genResourceIds: ->
      _.map @connectionTargets(), (resource) ->
        resource.createRef constant.AWS_RESOURCE_KEY[ resource.type ]



  }, {
    deserialize: ( data, layout_data, resolve ) ->
      tagItem = new TagItem( key: data.Key, value: data.Value, inherit: data.PropagateAtLaunch )

      for id in data.ResourceIds
        resource = resolve MC.extractID id
        continue unless resource

        new TagUsage resource, tagItem

      tagItem
  }

  # AsgTagModel will inherit TagModel, so method in TagModel must consider situation of AsgTagModel
  TagModel = GroupModel.extend {
    type: constant.RESTYPE.TAG

    serialize : ->
      component :
        name : @get("name")
        type : @type
        uid  : @id
        resource : _.invoke (_.filter @all(), (item) -> !!item.connections().length), 'serialize'

    addTag: (resource, tagKey, tagValue, inherit) ->
      tagItem = @find tagKey, tagValue, inherit

      inherit = true if @type is constant.RESTYPE.ASGTAG and inherit is undefined
      inherit = undefined if @type is constant.RESTYPE.TAG

      tagItem = new TagItem( { key: tagKey, value: tagValue, inherit: inherit, __parent: @ } ) unless tagItem

      # inherit is not a key attribute,
      # a resource can't have two tags with same key and value but different with inherit.
      if inherit isnt undefined
        dupTag = @find( tagKey, tagValue, !inherit )
        @removeTag resource, dupTag if dupTag

      new TagUsage resource, tagItem

    find: ( key, value, inherit ) ->
      prop = key: key
      prop.value = value if arguments.length > 1
      prop.inherit = inherit if arguments.length > 2

      _.find @all(), (item) -> _.isEqual( item.pick( _.keys(prop) ), prop )

    removeTag: ( resource, tagItem ) ->
      (new TagUsage resource, tagItem).remove()

    all: -> @children()


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
