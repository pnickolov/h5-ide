
define ["ide/cloudres/CrCollection"], ( CrCollection )->

  ###
    resourceType : a string used to identified a class of resource
    category     : a string used to group a set of resources. It might be a region id, or app id.
    platform     : optional string used to identified the platform, currently only support aws.
  ###

  CachedCollections = {}

  onCollectionDestroy = (id)-> delete CachedCollections[ id ]

  CloudResources = ( resourceType, category )->

    Collection = CrCollection.getClassByType( resourceType )

    if not Collection then return null

    category = Collection.category( category )

    cid = resourceType + "_" + category

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

  CloudResources
