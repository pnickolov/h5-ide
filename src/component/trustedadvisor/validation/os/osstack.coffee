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

            existMap = {}
            # existMap[constant.RESTYPE.OSSERVER]     = CloudResources( constant.RESTYPE.OSSERVER, region ).length
            existMap[constant.RESTYPE.OSPORT]       = CloudResources( constant.RESTYPE.OSPORT, region ).length
            # existMap[constant.RESTYPE.OSVOL]        = CloudResources( constant.RESTYPE.OSVOL, region ).length
            # existMap[constant.RESTYPE.OSSNAP]       = CloudResources( constant.RESTYPE.OSSNAP, region ).length
            existMap[constant.RESTYPE.OSFIP]        = CloudResources( constant.RESTYPE.OSFIP, region ).length
            existMap[constant.RESTYPE.OSRT]         = CloudResources( constant.RESTYPE.OSRT, region ).length
            # existMap[constant.RESTYPE.OSPOOL]       = CloudResources( constant.RESTYPE.OSPOOL, region ).length
            # existMap[constant.RESTYPE.OSLISTENER]   = CloudResources( constant.RESTYPE.OSLISTENER, region ).length
            existMap[constant.RESTYPE.OSSG]         = CloudResources( constant.RESTYPE.OSNETWORK, region ).length
            existMap[constant.RESTYPE.OSSUBNET]     = CloudResources( constant.RESTYPE.OSSUBNET, region ).length

            newMap = {}
            getNewCount = (type) ->
                return _.filter(Design.modelClassForType(type).allObjects(), (model) -> not model.get('appId')).length

            # newMap[constant.RESTYPE.OSSERVER]       = getNewCount(constant.RESTYPE.OSSERVER)
            newMap[constant.RESTYPE.OSPORT]         = getNewCount(constant.RESTYPE.OSPORT)
            # newMap[constant.RESTYPE.OSVOL]          = getNewCount(constant.RESTYPE.OSVOL)
            # newMap[constant.RESTYPE.OSSNAP]         = getNewCount(constant.RESTYPE.OSSNAP)
            newMap[constant.RESTYPE.OSFIP]          = getNewCount(constant.RESTYPE.OSFIP)
            newMap[constant.RESTYPE.OSRT]           = getNewCount(constant.RESTYPE.OSRT)
            # newMap[constant.RESTYPE.OSPOOL]         = getNewCount(constant.RESTYPE.OSPOOL)
            # newMap[constant.RESTYPE.OSLISTENER]     = getNewCount(constant.RESTYPE.OSLISTENER)
            newMap[constant.RESTYPE.OSSG]           = getNewCount(constant.RESTYPE.OSSG)
            newMap[constant.RESTYPE.OSSUBNET]       = getNewCount(constant.RESTYPE.OSSUBNET)

            limitMap = {}
            # limitMap[constant.RESTYPE.OSSERVER]     = quotaMap['Nova::instances']
            limitMap[constant.RESTYPE.OSPORT]       = quotaMap['Neutron::port']
            # limitMap[constant.RESTYPE.OSVOL]        = quotaMap['Cinder::volumes']
            # limitMap[constant.RESTYPE.OSSNAP]       = quotaMap['Cinder::snapshots']
            limitMap[constant.RESTYPE.OSFIP]        = quotaMap['Neutron::floatingip']
            limitMap[constant.RESTYPE.OSRT]         = quotaMap['Neutron::router']
            # limitMap[constant.RESTYPE.OSPOOL]       = quotaMap['']
            # limitMap[constant.RESTYPE.OSLISTENER]   = quotaMap['']
            # limitMap[constant.RESTYPE.OSNETWORK]    = quotaMap['Neutron::network']
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
