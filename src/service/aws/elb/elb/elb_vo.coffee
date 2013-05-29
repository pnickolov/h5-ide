#*************************************************************************************
#* Filename     : elb_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:15
#* Description  : vo define for elb
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    elb = {
        'LoadBalancerDescriptions'          :   ''
        'NextMarker'                        :   ''
    }

    elb_polocies = {
        'Description'                       :   ''
        'PolicyAttributeTypeDescriptions'   :   ''
        'PolicyTypeName'                    :   ''
    }

    elb_policy_types = {
        'AttributeName'                     :   ''
        'AttributeType'                     :   ''
        'Cardinality'                       :   ''
        'DefaultValue'                      :   ''
        'Description'                       :   ''
    }

    elb_instance_health = {
        'Description'                       :   ''
        'InstanceId'                        :   ''
        'ReasonCode'                        :   ''
        'State'                             :   ''
    }

    component =   {
        'UID'   :   {
            'type'  :   'AWS.ELB',
            'name'  :   '',
            'uid'   :   '',
            'resource'  :   {
                'AvailabilityZones' :   [],
                'BackendServerDescriptions' :   [
                    {
                        'InstantPort'   :   '',
                        'PoliciyNames'  :   '',
                        'KeyData'       :   ''
                    }
                ],
                'CanonicalHostedZoneName'   :   '',
                'CanonicalHostedZoneNameID' :   '',
                'CreatedTime'   :   '',
                'DNSName'       :   '',
                'HealthCheck'   :   {
                    'HealthyThreshold'  :   1,
                    'Interval'  :   1,
                    'Target'    :   '',
                    'Timeout'   :   1,
                    'UnhealthyThreshold'    :   1
                },
                'Instances' :   [
                    {
                        'InstanceId'    :   ''
                    }
                ],
                'ListenerDescriptions'  :   [
                    {
                        'Listener'  :   {
                            'InstancePort'  :   1,
                            'InstanceProtocol'  :   '',
                            'LoadBalancerPort'  :   1,
                            'Protocol'          :   '',
                            'SSLCertificateId'  :   ''
                        },
                        'PolicyNames'   :   ''
                    }
                ],
                'LoadBalancerName'  :   '',
                'Policies'  :   {
                    'AppCookieStickinessPolicies'   :   [
                        {
                            'CookieName'    :   '',
                            'PolicyName'    :   ''
                        }
                    ],
                    'LBCookieStickinessPolicies'    :   [
                        {
                            'CookieExpirationPeriod'    :   1,
                            'PolicyName'                :   ''
                        }
                    ],
                    'OtherPolicies' :   [
                        {
                            'PolicyName' : '',
                            'PolicyTypeName'    :   '',
                            'PolicyAttributes'  :   [{
                                'AttributeName' :   '',
                                'AttributeValue':   ''
                            }],
                            'LoadBalancerName'  :   ''
                        }
                    ]
                },
                'Scheme'    :   '',
                'SecurityGroups'    :   [],
                'SourceSecurityGroup'   :   {
                    'GroupName' :   '',
                    'OwnerAlias'    :   ''
                },
                'Subnets'   :   [],
                'VPCId' :   ''
                
            }
        }
    }
    #public
    #TO-DO

