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
            temp         = {}
            #
            _.each MC.ta.list, ( obj ) ->
                temp = { 'info' : obj.info, 'key' : obj.key, 'type' : obj.type }
                switch obj.level
                    when 'NOTICE'  then notice_list.push  temp
                    when 'WARNING' then warning_list.push temp
                    when 'ERROR'   then error_list.push   temp
            #
            @.set 'notice_list',   notice_list
            @.set 'warning_list', warning_list
            @.set 'error_list',   error_list
            #
            MC.ta.state_list = { 'notice_list' : notice_list, 'warning_list' : warning_list, 'error_list' : error_list }
            return

    }

    return TrustedAdvisorModel
