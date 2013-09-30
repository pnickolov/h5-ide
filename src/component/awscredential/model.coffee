#############################
#  View Mode for component/awscredential
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'session_model', 'vpc_model', 'account_model' ], (Backbone, $, _, MC, session_model, vpc_model, account_model) ->

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

                else

                    me.trigger 'UPDATE_ACCOUNT_ATTRIBUTES_FAILED', attributes

                null

            ###################################################

            #####listen SESSION_SYNC__REDIS_RETURN
            me.on 'SESSION_SYNC__REDIS_RETURN', (result) ->
                console.log 'SESSION_SYNC__REDIS_RETURN'

                if !result.is_error
                    # update aws credential
                    ide_event.trigger ide_event.UPDATE_AWS_CREDENTIAL

                null

            ###################################################

            #
            flag = false
            if MC.forge.cookie.getCookieByName('has_cred') is 'true'
                flag = true
            me.set 'is_authenticated', flag

            if MC.forge.cookie.getCookieByName('account_id')
                me.set 'account_id', MC.forge.cookie.getCookieByName('account_id')

        awsAuthenticate : (access_key, secret_key, account_id) ->
            me = this
            option = { expires:1, path: '/' }
            session_model.set_credential {sender: this}, $.cookie( 'usercode' ), $.cookie( 'session_id' ), access_key, secret_key, account_id

            me.once 'SESSION_SET__CREDENTIAL_RETURN', (result1) ->
                console.log 'SESSION_SET__CREDENTIAL_RETURN'
                console.log result1

                if !result1.is_error

                    # check credential
                    vpc_model.DescribeAccountAttributes { sender : vpc_model }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), '',  ["supported-platforms", "default-vpc"]

                    vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', (result) ->

                        console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'


                        if !result.is_error
                            me.set 'is_authenticated', true
                            MC.forge.cookie.setCookieByName 'has_cred', true
                            #MC.forge.cookie.setCookieByName 'new_account', false if MC.forge.cookie.getCookieByName( 'new_account' ) is 'true'
                            MC.forge.cookie.setIDECookie $.cookie()
                        else
                            me.set 'is_authenticated', false
                            MC.forge.cookie.setCookieByName 'has_cred', false

                        me.set 'account_id', account_id

                        me.trigger 'REFRESH_AWS_CREDENTIAL'

                else

                    me.set 'is_authenticated', false
                    MC.forge.cookie.setCookieByName 'has_cred', false

                    me.set 'account_id', account_id

                    me.trigger 'REFRESH_AWS_CREDENTIAL'

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
            me = this

            session_model.sync_redis {sender:me}, $.cookie('usercode'), $.cookie('session_id')

            null

    }

    return AWSCredentialModel