
define ["ApiRequest", "./CrCollection", "./CrModel"], ( ApiRequest, CrCollection, CrModel )->

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
            for d in self.parseFetchData( $.xml2json( $.parseXML(dataXml[0]) ) ) || EmptyArr
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
