#*************************************************************************************
#* Filename     : instance_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 17:15:13
#* Description  : qunit testsuite for instance_service
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
	'/test/service/aws/rds/module_instance.js',
	'/test/service/aws/rds/module_optiongroup.js',
	'/test/service/aws/rds/module_parametergroup.js',
	'/test/service/aws/rds/module_rds.js',
	'/test/service/aws/rds/module_reservedinstance.js',
	'/test/service/aws/rds/module_securitygroup.js',
	'/test/service/aws/rds/module_snapshot.js',
	'/test/service/aws/rds/module_subnetgroup.js',
	##@@module-list
]

# Resolve all testModules and then start the Test Runner.
#!!Do not use QUnit.start
require testModules, QUnit.load
