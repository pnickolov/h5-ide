#############################
#  View Mode for component/awscredential
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'session_model', 'vpc_model' ], (Backbone, $, _, MC, session_model, vpc_model) ->

    AWSCredentialModel = Backbone.Model.extend {

        defaults :
            'account_id'        : null
            'is_authenticated'  : null
            'is_update'         : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        awsAuthenticate : (access_key, secret_key, account_id) ->
            me = this

            is_authenticated = false

            session_model.set_credential {sender: this}, $.cookie( 'usercode' ), $.cookie( 'session_id' ), access_key, secret_key, account_id

            me.once 'SESSION_SET__CREDENTIAL_RETURN', (result1) ->
                console.log 'SESSION_SET__CREDENTIAL_RETURN'
                console.log result1

                if !result1.is_error
                    vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), 'us-east-1',  ["supported-platforms"]

                    me.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', (result2) ->

                        console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                        if !result2.is_error
                            is_authenticated = true
                        else
                            is_authenticated = false

                        me.set 'account_id', account_id
                        me.set 'is_authenticated', is_authenticated

                        me.trigger 'UPDATE_AWS_CREDENTIAL'

                    null

                else
                    is_authenticated = false

                    me.set 'account_id', account_id
                    me.set 'is_authenticated', is_authenticated

                    me.trigger 'UPDATE_AWS_CREDENTIAL'

            null

    }

    return AWSCredentialModel