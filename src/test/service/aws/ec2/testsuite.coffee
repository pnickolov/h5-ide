#*************************************************************************************
#* Filename     : ami_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-29 14:09:35
#* Description  : qunit testsuite for ami_service
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
	'/test/service/aws/ec2/module_ami.js',
	'/test/service/aws/ec2/module_ebs.js',
	'/test/service/aws/ec2/module_ec2.js',
	'/test/service/aws/ec2/module_eip.js',
	'/test/service/aws/ec2/module_instance.js',
	'/test/service/aws/ec2/module_keypair.js',
	'/test/service/aws/ec2/module_placementgroup.js',
	'/test/service/aws/ec2/module_securitygroup.js',
	##@@module-list
]

# Resolve all testModules and then start the Test Runner.
#!!Do not use QUnit.start
require testModules, QUnit.load
