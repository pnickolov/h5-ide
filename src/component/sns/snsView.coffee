define [ 'constant', 'CloudResources' ], ( constant, CloudResources ) ->


    snsCol = CloudResources constant.RESTYPE.SUBSCRIPTION, 'us-east-1'
    topicCol = CloudResources constant.RESTYPE.TOPIC, 'us-east-1'


    window.snsCol = snsCol
    window.topicCol = topicCol
