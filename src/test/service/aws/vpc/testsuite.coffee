#*************************************************************************************
#* Filename     : acl_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:22
#* Description  : qunit testsuite for acl_service
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

# Defer Qunit so RequireJS can work its magic and resolve all modules.
#!!Must be false
QUnit.config.autostart = false

# A list of all QUnit test Modules.  Make sure you include the `.js`
# extension so RequireJS resolves them as relative paths rather than using
# the `baseUrl` value supplied above.
testModules = [
	# '/test/service/aws/vpc/module_acl.js',
	# '/test/service/aws/vpc/module_customergateway.js',
	# '/test/service/aws/vpc/module_dhcp.js',
	# '/test/service/aws/vpc/module_eni.js',
	# '/test/service/aws/vpc/module_internetgateway.js',
	# '/test/service/aws/vpc/module_routetable.js',
	# '/test/service/aws/vpc/module_subnet.js',
	'/test/service/aws/vpc/module_vpc.js',
	# '/test/service/aws/vpc/module_vpngateway.js',
	# '/test/service/aws/vpc/module_vpn.js',
	##@@module-list
]

# Resolve all testModules and then start the Test Runner.
#!!Do not use QUnit.start
require testModules, QUnit.load
