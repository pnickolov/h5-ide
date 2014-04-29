#############################
#  View Mode for component/awscredential
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'vpc_model', 'account_model', 'i18n!nls/lang.js', 'event', 'constant', 'ApiRequest', 'UI.notification'
], (Backbone, $, _, MC, vpc_model, account_model, lang, ide_event, constant, ApiRequest) ->

    AWSCredentialModel = Backbone.Model.extend {

        defaults :
            'account_id'        : null
            'is_authenticated'  : null

        initialize : ->
            me = this

            #####listen ACCOUNT_UPDATE__ACCOUNT_RETURN
            me.on 'ACCOUNT_UPDATE__ACCOUNT_RETURN', (result) ->
                console.log 'ACCOUNT_UPDATE__ACCOUNT_RETURN'

                attributes = result.param[3]

                if !result.is_error

                    me.trigger 'UPDATE_ACCOUNT_ATTRIBUTES_SUCCESS', attributes

                    if attributes.state is '3'
                        #
                        MC.common.cookie.setCookieByName 'state', attributes.state
                else

                    me.trigger 'UPDATE_ACCOUNT_ATTRIBUTES_FAILED', attributes

                null

            ###################################################

            #####listen ACCOUNT_RESET__KEY_RETURN
            me.on 'ACCOUNT_RESET__KEY_RETURN', (result) ->
                console.log 'ACCOUNT_RESET__KEY_RETURN'

                flag = result.param[3]

                if !result.is_error
                    console.log 'reset key successfully'
                    #
                    if not flag or flag == 0    # last key -> key
                        me.set 'is_authenticated', true
                        me.set 'account_id', result.resolved_data
                        #
                        MC.common.cookie.setCookieByName 'account_id', result.resolved_data
                        MC.common.cookie.setCookieByName 'has_cred',   true
                        #
                        me.trigger 'REFRESH_AWS_CREDENTIAL'

                else

                    console.log 'reset key failed'

                null

            ###################################################

            #
            flag = false
            if MC.common.cookie.getCookieByName('has_cred') is 'true'
                flag = true
            me.set 'is_authenticated', flag

            if MC.common.cookie.getCookieByName('account_id')
                me.set 'account_id', MC.common.cookie.getCookieByName('account_id')

        awsAuthenticate : (access_key, secret_key, account_id) ->
            me = this

            ApiRequest("updateCred", {
                access_key : access_key
                secret_key : secret_key
                account_id : account_id
            }).then ( result )->
                name = 'DescribeAccountAttributes' + '_' + $.cookie( 'usercode' ) + '__' + 'supported-platforms,default-vpc'
                if MC.session.get name
                    MC.session.remove name

                # check credential
                vpc_model.DescribeAccountAttributes { sender : vpc_model }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), '',  ["supported-platforms", "default-vpc"]

                vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', (result) ->

                    console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'


                    if !result.is_error
                        me.set 'is_authenticated', true
                        MC.common.cookie.setCookieByName 'has_cred',   true
                        MC.common.cookie.setCookieByName 'account_id', account_id

                        # update account attributes
                        regionAttrSet = result.resolved_data
                        _.map constant.REGION_KEYS, ( value ) ->
                            if regionAttrSet[ value ] and regionAttrSet[ value ].accountAttributeSet

                                #resolve support-platform
                                support_platform = regionAttrSet[ value ].accountAttributeSet.item[0].attributeValueSet.item
                                if support_platform and $.type(support_platform) == "array"
                                    if support_platform.length == 2
                                        MC.data.account_attribute[ value ].support_platform = support_platform[0].attributeValue + ',' + support_platform[1].attributeValue
                                    else if support_platform.length == 1
                                        MC.data.account_attribute[ value ].support_platform = support_platform[0].attributeValue

                                #resolve default-vpc
                                default_vpc = regionAttrSet[ value ].accountAttributeSet.item[1].attributeValueSet.item
                                if  default_vpc and $.type(default_vpc) == "array" and default_vpc.length == 1
                                    MC.data.account_attribute[ value ].default_vpc = default_vpc[0].attributeValue
                            null

            , ( error )=>
                @set 'is_authenticated', false
                MC.common.cookie.setCookieByName 'has_cred', false

                @set 'account_id', account_id

                @trigger 'REFRESH_AWS_CREDENTIAL'

            null

        updateAccountEmail : (new_email) ->
            me = this

            attributes = {'email':new_email}

            account_model.update_account {sender:me}, $.cookie('usercode'), $.cookie('session_id'), attributes

            null

        updateAccountPassword : (password, new_password) ->
            me = this

            attributes = {'password':password, 'new_password':new_password}

            account_model.update_account {sender:me}, $.cookie('usercode'), $.cookie('session_id'), attributes

            null

        removeCredential : () ->
            me = this

            attributes = {'account_id':null, 'access_key':null, 'secret_key':null}

            account_model.update_account {sender:me}, $.cookie('usercode'), $.cookie('session_id'), attributes

            null

        sync_redis : () ->
            ApiRequest("syncRedis").then ()->
                ide_event.trigger ide_event.UPDATE_AWS_CREDENTIAL
            null

        resetKey : ( flag ) ->
            console.log 'reset key, flag:' + flag
            account_model.reset_key {sender:this}, $.cookie('usercode'), $.cookie('session_id'), flag
            null

        updateAccountService : ->
            console.log 'updateAccountService'
            account_model.update_account {sender:this}, $.cookie('usercode'), $.cookie('session_id'), { 'state' : '3' }

    }

    return AWSCredentialModel
