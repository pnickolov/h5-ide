#############################
#  View(UI logic) for component/awscredential
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.modal', 'UI.notification'
], ( ide_event ) ->

    AWSCredentialView = Backbone.View.extend {

        events   :
            'closed'                      : 'onClose'
            'click #awsredentials-submit' : 'onSubmit'

        render     : ( template ) ->
            console.log 'pop-up:awscredential render'
            #
            modal template, false
            #
            this.setElement $( '#AWSCredential-setting' ).closest '#modal-wrap'

        onClose : ->
            console.log 'onClose'
            this.trigger 'CLOSE_POPUP'

        onSubmit : () ->
            console.log 'onSubmit'
            # input check
            account_id = $('#aws-credential-account-id').val()
            access_key = $('#aws-credential-access-key').val()
            secret_key = $('#aws-credential-secret-key').val()

            if not account_id
                notification 'error', 'Invalid accout id.'
            else if not access_key
                notification 'error', 'Invalid access key.'
            else if not secret_key
                notification 'error', 'Invalid secret key.'

            this.trigger 'AWS_AUTHENTICATION', account_id, access_key, secret_key

    }

    return AWSCredentialView