#*************************************************************************************
#* Filename     : iam_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:16
#* Description  : vo define for iam
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    server_certificate = {
        'IsTruncated'           :   ''
        'Marker'                :   ''
        'ServerCertificateMetadataList' :   []
    }

    component   =   {
        'type'  :   'AWS.IAM.ServerCertificate',
        'name'  :   '',
        'uid'   :   '',
        'resource'  :   {
            'CertificateBody'       :   '',
            'CertificateChain'      :   '',
            'PrivateKey'            :   '',
            'ServerCertificateMetadata' :   {
                'Arn'   :   '',
                'Path'  :   '',
                'ServerCertificateId'   :   '',
                'ServerCertificateName' :   '',
                'UploadDate'            :   ''
            }
        }
    }

    #public
    server_certificate : server_certificate

