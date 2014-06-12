
define ["ApiRequest", "./CrCollection", "./CrModel", "constant"], ( ApiRequest, CrCollection, CrModel, constant )->

  # Common Collection is a base class for all the non-shared resources.
  # For example, elb / volume / ami / eip things

  # Subclass of CrModel that is used for common resource should have an attribute called : "category"

  EmptyArr = []

  CrCommonCollection = CrCollection.extend {
    ### env:dev ###
    ClassName : "CrCommonCollection"
    ### env:dev:end ###

    model : CrModel

    type : "CrCommonCollection"
    __selfParseData : true

    # Returns an array of datas that are grouped by category(a.k.a region)
    groupByCategory : ( opts, filter )->
      opts = opts || {
        includeEmptyRegion : true
        calcSum            : true
        toJSON             : false
      }

      # Group model by region
      regionMap = {}
      for m in @models
        if filter and filter( m ) is false then continue

        r = m.attributes.category
        list = regionMap[r] || (regionMap[r] = [])
        list.push(if opts.toJSON then m.toJSON() else m)

      # Sort group
      totalCount = 0
      regions = []
      for R in constant.REGION_KEYS
        models = regionMap[ R ]

        if models
          totalCount += models.length
        else if not opts.includeEmptyRegion
          continue

        regions.push {
          region : R
          regionName : constant.REGION_SHORT_LABEL[ R ]
          regionArea : constant.REGION_LABEL[ R ]
          data : models || []
        }

      if opts.calcSum then regions.totalCount = totalCount
      regions



    doFetch : ()->
      param = {}
      param[ @type ] = {}

      self = @

      ApiRequest("aws_resource", {
        region_name : null
        resources   : param
        addition    : "all"
        retry_times : 1
      }).then ( data )->
        # The returned data of "aws_resource" will returns an xml map of all the regions.
        # We need to join the data first.
        transformed = []
        for regionId, dataXml of data
          try
            xml = $.xml2json( $.parseXML(dataXml[0]) )

            if self.trAwsXml then xml = self.trAwsXml( xml )
            if self.parseFetchData and xml then xml = self.parseFetchData( xml )

            for d in xml || EmptyArr
              if self.modelIdAttribute
                d.id = d[ self.modelIdAttribute ]
                delete d[ self.modelIdAttribute ]
              d.category = regionId
              transformed.push( new self.model(d) )
          catch e
            # Drop this regions data if we cannot parse it.
            # This might not be elegent but we can improve this later.
            continue

        transformed

  }, {
    category : ()-> "" # All the common resources are global-wise.
  }

  CrCommonCollection
