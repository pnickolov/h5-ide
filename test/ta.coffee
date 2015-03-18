browser = require('./env/Browser')
window = browser.window

$ = window.$
App = window.App

Design = window.Design
MC     = window.MC

# Initialize Data

region = 'us-east-1'

project = App.sceneManager.activeScene().project

OpsModel = project.stacks().model
ops = new OpsModel( region: region )
ops.__setJsonData ops.__defaultJson()

project.stacks().add ops

design = new Design ops

# Models
VpcModel    = Design.modelClassForType 'AWS.VPC.VPC'
AzModel     = Design.modelClassForType 'AWS.EC2.AvailabilityZone'
SubnetModel = Design.modelClassForType 'AWS.VPC.Subnet'
AsgModel    = Design.modelClassForType('AWS.AutoScaling.Group')
LcModel     = Design.modelClassForType('AWS.AutoScaling.LaunchConfiguration')

vpc     = new VpcModel()
az      = new AzModel __parent: vpc
subnet  = new SubnetModel __parent:az


# Utils
ta = ( compModel ) ->
    MC.ta.validAll()

# Define expect like { ERROR: 1, WARNING: 1, NOTICE: 2 }
assert = ( result, expect ) ->
    levelCount = { ERROR: 0, WARNING: 0, NOTICE: 0 }

    for r in result
        levelCount[ r.level ]+=1

    for level, count of expect
        if count isnt levelCount[ level ]
            throw new Error "Expected #{levelCount[ level ]} #{level}, but there is #{levelCount[ level ]}"

    true






describe "TA", ()->
    console.log '------------------------'
    console.log 'TA Testing'
    console.log '------------------------'

    it "asg.isHasLaunchConfiguration", () ->
        asg = new AsgModel __parent: subnet
        assert ta(), ERROR: 1

        lc = new LcModel()
        asg.setLc lc

        assert ta(), ERROR: 0





