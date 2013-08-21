#############################
#  View Mode for component/awscredential
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'session_model', 'vpc_model' ], (Backbone, $, _, MC, session_model, vpc_model) ->

    AWSCredentialModel = Backbone.Model.extend {

        defaults :
            'account_id'        : null
            'is_authenticated'  : null
            'is_update'         : null
            'is_region'         : null  # whether on the region tab

        initialize : ->
            me = this
            #
            if $.cookie('account_id')
                me.set 'is_authenticated', true
                me.set 'account_id', $.cookie('account_id')
            else
                me.set 'is_authenticated', false

        awsAuthenticate : (access_key, secret_key, account_id) ->
            me = this

            session_model.set_credential {sender: this}, $.cookie( 'usercode' ), $.cookie( 'session_id' ), access_key, secret_key, account_id

            me.once 'SESSION_SET__CREDENTIAL_RETURN', (result1) ->
                console.log 'SESSION_SET__CREDENTIAL_RETURN'
                console.log result1

                if !result1.is_error

                    me.credentialCheck()
                    me.set 'account_id', account_id
                    me.trigger 'UPDATE_AWS_CREDENTIAL'

                else

                    me.set 'account_id', account_id
                    me.set 'is_authenticated', false
                    me.trigger 'UPDATE_AWS_CREDENTIAL'

            null

        credentialCheck : () ->
            me = this

            vpc_model.DescribeAccountAttributes { sender : vpc_model }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), '',  ["supported-platforms"]

            vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', (result) ->

                console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                flag = false
                if !result.is_error
                    flag = true

                me.set 'is_authenticated', flag

    }

    return AWSCredentialModel