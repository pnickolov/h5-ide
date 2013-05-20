
# Defer Qunit so RequireJS can work its magic and resolve all modules.
#!!Must be false
QUnit.config.autostart = false

# A list of all QUnit test Modules.  Make sure you include the `.js`
# extension so RequireJS resolves them as relative paths rather than using
# the `baseUrl` value supplied above.
testModules = [
	"/test/service/aws/ec2/instance.js"
]

# Resolve all testModules and then start the Test Runner.
#!!Do not use QUnit.start
require testModules, QUnit.load
