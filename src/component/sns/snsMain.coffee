define [ 'constant', 'CloudResources' ], ( constant, CloudResources ) ->


    snsCol = CloudResources constant.RESTYPE.SUBSCRIPTION, Design.instance().region()

    window.snsCol = snsCol