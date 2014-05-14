
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define [ "./OpsModel", "constant", "backbone" ], ( OpsModel, constant )->

  Backbone.Collection.extend {
    model      : OpsModel
    comparator : ( m1, m2 )-> -(m1.attributes.updateTime - m2.attributes.updateTime)

    initialize : ()->
      # Re-sort the collection when any model is updated.
      @on "change:updateTime", @sort, @
      return

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
  }
