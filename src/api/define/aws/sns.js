define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'sns_GetSubscriptionAttributes'          : { type:'aws', url:'/aws/sns/',	method:'GetSubscriptionAttributes',	params:['username', 'session_id', 'region_name', 'subscription_arn']   },
		'sns_GetTopicAttributes'                 : { type:'aws', url:'/aws/sns/',	method:'GetTopicAttributes',	params:['username', 'session_id', 'region_name', 'topic_arn']   },
		'sns_ListSubscriptions'                  : { type:'aws', url:'/aws/sns/',	method:'ListSubscriptions',	params:['username', 'session_id', 'region_name', 'next_token']   },
		'sns_SetSubscriptionAttributes'          : { type:'aws', url:'/aws/sns/',	method:'SetSubscriptionAttributes',	params:['username', 'session_id', 'region_name', 'subscription_arn', 'attr_name', 'attr_value']   },
		'sns_ListSubscriptionsByTopic'           : { type:'aws', url:'/aws/sns/',	method:'ListSubscriptionsByTopic',	params:['username', 'session_id', 'region_name', 'topic_arn', 'next_token']   },
		'sns_Subscribe'                          : { type:'aws', url:'/aws/sns/',	method:'Subscribe',	params:['username', 'session_id', 'region_name', 'topic_arn', 'protocol', 'endpoint']   },
		'sns_Unsubscribe'                        : { type:'aws', url:'/aws/sns/',	method:'Unsubscribe',	params:['username', 'session_id', 'region_name', 'sub_arn']   },
		'sns_ListTopics'                         : { type:'aws', url:'/aws/sns/',	method:'ListTopics',	params:['username', 'session_id', 'region_name', 'next_token']   },
		'sns_DeleteTopic'                        : { type:'aws', url:'/aws/sns/',	method:'DeleteTopic',	params:['username', 'session_id', 'region_name', 'topic_arn']   },
		'sns_CreateTopic'                        : { type:'aws', url:'/aws/sns/',	method:'CreateTopic',	params:['username', 'session_id', 'region_name', 'topic_name']   },
		'sns_SetTopicAttributes'                 : { type:'aws', url:'/aws/sns/',	method:'SetTopicAttributes',	params:['username', 'session_id', 'region_name', 'topic_arn', 'attr_name', 'attr_value']   },
	}

	for ( var i in Apis ) {
		/* env:dev */
		if (ApiRequestDefs.Defs[ i ]){
			console.warn('api duplicate: ' + i);
		}
		/* env:dev:end */
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
