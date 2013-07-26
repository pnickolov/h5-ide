#############################
#  View(UI logic) for component/awscredential
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.modal'
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

        onSubmit : ->
            console.log 'onSubmit'

    }

    return AWSCredentialView