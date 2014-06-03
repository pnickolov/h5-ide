
define ["ide/cloudres/CrCollection"], ( CrCollection )->

  ###
    resourceType : a string used to identified a class of resource
    category     : a string used to group a set of resources. It might be a region id, or app id.
    platform     : optional string used to identified the platform, currently only support aws.
  ###

  CachedCollections = {}

  onCollectionDestroy = (id)-> delete CachedCollections[ id ]

  CloudResources = ( resourceType, category, platform = "AWS" )->

    classId    = CrCollection.classId( resourceType, platform )
    Collection = CrCollection.getClassById( classId )

    if not Collection then return null

    category   = Collection.category( category )

    cid = classId + "_" + category

    c = CachedCollections[ cid ]
    if not c
      c = new Collection()
      c.id = cid
      c.category = category
      CachedCollections[ cid ] = c
      c.on "destroy", onCollectionDestroy

    c

  # Invalidate all the resources in every collection.
  CloudResources.invalidate = ()->
    collection.fetchForce() for id, collection of CachedCollections
    return

  # A convenient method that can be used to parse response from aws.
  # It's not garunteed that the data can be parse. If it cannot parse the data, it returns null.
  # If the data can be parsed, then the item in the data would be added to current collection.
  # And returns an array of the parsed model.
  CloudResources.parseResponse = ( type, data )->
    cln = CloudResources( type, "" )
    if not cln then return null
    try
      return cln.parseExternalData( data )
    catch e
      return null

  CloudResources
