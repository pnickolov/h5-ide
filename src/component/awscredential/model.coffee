#############################
#  View Mode for component/awscredential
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC', 'session_model', 'vpc_model' ], (Backbone, $, _, MC, session_model, vpc_model) ->

    AWSCredentialModel = Backbone.Model.extend {

        defaults :
            'aws_credential'    : null
            'is_authenticated'  : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        awsAuthenticate : (access_key, secret_key, account_id) ->
            me = this

            is_authenticated = false

            session_model.set_credential {sender: this}, $.cookie( 'usercode' ), $.cookie( 'session_id' ), access_key, secret_key, account_id

            session_model.once 'SESSION_SET__CREDENTIAL_RETURN', (result) ->
                console.log 'SESSION_SET__CREDENTIAL_RETURN'
                console.log result

                if !result.is_error
                    is_authenticated = true
                else
                    is_authenticated = false

                null

            me.set 'aws_credential', {'account_id' : account_id, 'access_key' : access_key, 'secret_key' : secret_key}

            # invalid checking
            if is_authenticated

                vpc_model.DescribeAccountAttributes { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), 'us-east-1',  ["supported-platforms"]

                vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', ( result ) ->

                    console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

                    if !result.is_error
                        is_authenticated = true

                    else
                        is_authenticated = false

            me.set 'is_authenticated', is_authenticated

            me.trigger 'UPDATE_AWS_CREDENTIAL'

            null

    }

    return AWSCredentialModel