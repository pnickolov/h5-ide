define [
    'constant'
    'MC'
    'i18n!/nls/lang.js'
    'TaHelper'
    'CloudResources'
], ( constant, MC, lang, Helper, CloudResources ) ->

        i18n = Helper.i18n.short()

        isResExtendQuotaLimit = () ->

            # Cinder::gigabytes:
            # Cinder::id: "6071d14a95bf4fb5b216dcb2f53b4f52"
            # Cinder::snapshots: 1000
            # Cinder::volumes: 20000
            # Neutron::floatingip: 5000
            # Neutron::ikepolicy: -1
            # Neutron::ipsec_site_connection: -1
            # Neutron::ipsecpolicy: -1
            # Neutron::network: 1000
            # Neutron::port: 5000
            # Neutron::router: 1000
            # Neutron::security_group: 1000
            # Neutron::security_group_rule: 1000
            # Neutron::subnet: 1000
            # Neutron::vpnservice: -1
            # Nova::cores: 20000
            # Nova::fixed_ips: -1
            # Nova::floating_ips: 10
            # Nova::id: "6071d14a95bf4fb5b216dcb2f53b4f52"
            # Nova::injected_file_content_bytes: 10240
            # Nova::injected_file_path_bytes: 255
            # Nova::injected_files: 5
            # Nova::instances: 10000
            # Nova::key_pairs: 100
            # Nova::metadata_items: 128
            # Nova::ram: 512000000
            # Nova::security_group_rules: 20
            # Nova::security_groups: 10

            region = Design.instance().region()
            provider = App.user.get("default_provider")
            quotaMap = App.model.getOpenstackQuotas(provider)

            getNewCount = (type) ->
                return _.filter(Design.modelClassForType(type).allObjects(), (model) -> not model.get('appId')).length

            typeShortMap = {}

            existMap = {}
            newMap = {}
            limitMap = {}

            _.each [
                constant.RESTYPE.OSPORT,
                constant.RESTYPE.OSFIP,
                constant.RESTYPE.OSRT,
                constant.RESTYPE.OSSG,
                constant.RESTYPE.OSSUBNET
            ], (type) ->

                typeShortMap[type] =
                existMap[type] = CloudResources(type, region).length
                newMap[type] = getNewCount(type)

            limitMap[constant.RESTYPE.OSPORT]       = quotaMap['Neutron::port']
            limitMap[constant.RESTYPE.OSFIP]        = quotaMap['Neutron::floatingip']
            limitMap[constant.RESTYPE.OSRT]         = quotaMap['Neutron::router']
            limitMap[constant.RESTYPE.OSSG]         = quotaMap['Neutron::security_group']
            limitMap[constant.RESTYPE.OSSUBNET]     = quotaMap['Neutron::subnet']

            validAry = []
            _.each existMap, (count, type) ->

                usedCount = existMap[type] + newMap[type]
                limitCount = limitMap[type]

                typeName = constant.RESNAME[type]

                if usedCount > limitCount and typeName
                    validAry.push(Helper.message.error null, i18n.ERROR_STACK_RESOURCE_EXCCED_LIMIT, typeName, usedCount, limitCount)

                null

            return validAry

        isResExtendQuotaLimit: isResExtendQuotaLimit
