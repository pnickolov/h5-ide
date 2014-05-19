
###
----------------------------
  The collection for stack / app
----------------------------

  This collection will trigger an "update" event when the list ( containing all visible items ) is changed.

###

define [ "./OpsModel", "constant", "backbone" ], ( OpsModel, constant )->

  Backbone.Collection.extend {
    model       : OpsModel
    newNameTmpl : "untitled-"
    comparator  : ( m1, m2 )-> -(m1.attributes.updateTime - m2.attributes.updateTime)

    initialize : ()->
      # Re-sort the collection when any model is updated.
      @on "change:updateTime", @sort, @
      @on "add remove", @__triggerUpdate, @

      @__debounceUpdate = _.debounce ()-> @trigger "update"
      return

    # Returns a new name that can be used in a model. The name is garuntee to be identical.
    getNewName : ( possibleName )->
      # Collect all the resources name
      nameMap = @groupBy "name"
      base    = 0
      newName = possibleName || (@newNameTmpl + base)

      while true
        if nameMap[ newName ]
          base += 1
        else
          break
        newName = @newNameTmpl + base

      newName

    # Returns true if name is OK to be used.
    isNameAvailable : ( name )-> !!@.findWhere({name:name})

    # Returns a sorted array.
    groupByRegion : ( includeEmptyRegion = false, toJSON = true, includeEveryOps = false )->
      # Group model by region
      regionMap = {}
      for m in @models
        if not includeEveryOps and not m.isExisting() then continue

        r = m.attributes.region
        list = regionMap[r] || (regionMap[r] = [])
        list.push(if toJSON then m.toJSON() else m)

      # Sort group
      regions = []
      for R in constant.REGION_KEYS
        models = regionMap[ R ]
        if not models and not includeEmptyRegion then continue

        regions.push {
          region : R
          regionName : constant.REGION_SHORT_LABEL[ R ]
          data : models || []
        }

      regions

    # Returns an array containing models that are updated in the last 30 days.
    filterRecent : ( toJSON = false )->
      now = Math.round( +(new Date()) / 1000 )
      filters = []
      for m in @models
        time = m.get("updateTime")
        if now - time >= 2592000 then break

        if toJSON
          m = m.toJSON()
          m.formatedTime = MC.intervalDate( time )

        filters.push m

      filters

    __triggerUpdate : ( model )->
      if not model then return

      # When a model is added to the collection, we would only trigger and "update" event
      # if that model is visible to the list.
      if @indexOf( model ) != -1 and not model.isExisting() then return
      @__debounceUpdate()
      return
  }
