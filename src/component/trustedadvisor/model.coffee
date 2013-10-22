#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    TrustedAdvisorModel = Backbone.Model.extend {

        defaults :
            'notice_list'  : null
            'warning_list' : null
            'error_list'   : null

        createList : ->
            console.log 'createList'
            #
            notice_list  = []
            warning_list = []
            error_list   = []
            #
            _.each MC.ta.list, ( obj ) ->
            	switch obj.level
            		when 'NOTICE'  then notice_list.push  obj.info
            		when 'WARNING' then warning_list.push obj.info
            		when 'ERROR'   then error_list.push   obj.info
            #
            @.set 'notice_list',   notice_list
            @.set 'warning_list', warning_list
            @.set 'error_list',   error_list

    }

    return TrustedAdvisorModel