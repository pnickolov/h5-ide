
define ["ide/cloudres/CrCollection"], ( CrCollection )->

  ###
    resourceType : a string used to identified a class of resource
    category     : a string used to group a set of resources. It might be a region id, or app id.
    platform     : optional string used to identified the platform, currently only support aws.
  ###

  CachedCollections = {}

  CloudResources = ( resourceType, category, platform = "AWS" )->

    classId    = CrCollection.classId( resourceType, platform )
    Collection = CrCollection.getClassById( classId )
    category   = Collection.category( category )

    cid = classId + "_" + category

    c = CachedCollections[ cid ]
    if not c
      c = new Collection()
      c.id = cid
      c.category = category
      CachedCollections[ cid ] = c

    c

  CloudResources
