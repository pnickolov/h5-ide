
define ["cloudres/CrCollection"], ( CrCollection )->

  ###
    credentialId : a string used to identified which credential to be use.
    resourceType : a string used to identified a class of resource
    category     : a string used to group a set of resources. It might be a region id, or app id.
  ###

  CachedCollections = {}

  CloudResources = ( credentialId, resourceType, category )->

    console.assert credentialId, "Crendential is needed to create a CloudResource"
    console.assert resourceType, "Resource Type is neede to create a CloudResource"

    Collection = CrCollection.getClassByType( resourceType )
    if not Collection
      console.error "Can't find Cloud Resource Collection for type:", resourceType
      return null

    category = Collection.category( category )
    cid      = resourceType + "_" + category

    credCached = CachedCollections[ credentialId ] || (CachedCollections[ credentialId ] = {})
    c = credCached[ cid ]
    if not c
      c = credCached[cid] = new Collection()
      c.id = cid
      c.category     = category
      c.__credential = credentialId
      c.on "destroy", onCollectionDestroy
    c

  onCollectionDestroy = (credential, id)->
    if CachedCollections[credential][id]
      console.info "CloudResource collection is destroyed:", CachedCollections[credential][id]
    delete CachedCollections[ credential ][ id ]
    return

  # Invalidate all the resources in every collection.
  CloudResources.invalidate = ()->
    clns = []
    for cred, credCached of CachedCollections
      for id, cln of credCached
        clns.push cln

    Q.all clns.map ( cln )-> cln.fetchForce()

  # Returns an array of collection.
  CloudResources.collectionOfCredential = ( credentialId )-> CachedCollections[ credentialId ]

  # Clear all the resources which attribute matches `detect`
  CloudResources.clearWhere = ( credentialId, category, detect )->
    find = if _.isFunction(detect) then "filter" else "where"

    for id, cln of CachedCollections[credentialId] || []

      Collection = CrCollection.getClassByType( cln.type )
      realCate   = Collection.category( category )

      if cln.category is realCate
        console.log "Removing CloudResources:", cln[find](detect)
        cln.remove( cln[find](detect) )
    return

  CloudResources
