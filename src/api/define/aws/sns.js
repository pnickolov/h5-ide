define(['ApiRequestDefs'], function( ApiRequestDefs ){
	var Apis = {
		'sns_GetSubscriptionAttributes'          : { url:'/aws/sns/',	method:'GetSubscriptionAttributes',	params:['username', 'session_id', 'region_name', 'subscription_arn']   },
		'sns_GetTopicAttributes'                 : { url:'/aws/sns/',	method:'GetTopicAttributes',	params:['username', 'session_id', 'region_name', 'topic_arn']   },
		'sns_ListSubscriptions'                  : { url:'/aws/sns/',	method:'ListSubscriptions',	params:['username', 'session_id', 'region_name', 'next_token']   },
		'sns_ListSubscriptionsByTopic'           : { url:'/aws/sns/',	method:'ListSubscriptionsByTopic',	params:['username', 'session_id', 'region_name', 'topic_arn', 'next_token']   },
		'sns_ListTopics'                         : { url:'/aws/sns/',	method:'ListTopics',	params:['username', 'session_id', 'region_name', 'next_token']   },
	}

	for ( var i in Apis ) {
		ApiRequestDefs.Defs[ i ] = Apis[ i ];
	}

});
