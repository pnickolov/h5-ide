(function() {
  define(['MC', 'constant', 'underscore'], function(MC, constant, _) {
    var checkFullDefaultVPC, generateComponentForDefaultVPC, getAZSubnetForDefaultVPC, getSubnetForDefaultVPC, getVPCUID, updateAllSubnetCIDR;
    getVPCUID = function() {
      var vpcUID;
      vpcUID = '';
      _.each(MC.canvas_data.layout.component.group, function(groupObj, groupUID) {
        if (groupObj.type === 'AWS.VPC.VPC') {
          vpcUID = groupUID;
          return false;
        }
      });
      return vpcUID;
    };
    updateAllSubnetCIDR = function(vpcCIDR, oldVPCCIDR) {
      var needUpdateAllSubnetCIDR, newSimpleSubnetCIDRAry, newSubnetCIDRAry, oldSubnetAry, subnetCount, subnetNum;
      needUpdateAllSubnetCIDR = false;
      subnetCount = 0;
      oldSubnetAry = [];
      _.each(MC.canvas_data.component, function(compObj) {
        var subnetCIDR;
        if (compObj.type === constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet) {
          subnetCount++;
          subnetCIDR = compObj.resource.CidrBlock;
          oldSubnetAry.push(subnetCIDR);
          if (!MC.aws.subnet.isInVPCCIDR(vpcCIDR, subnetCIDR)) {
            needUpdateAllSubnetCIDR = true;
          }
        }
        if (compObj.type === constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable) {
          compObj.resource.RouteSet[0].DestinationCidrBlock = vpcCIDR;
        }
        return null;
      });
      if (!needUpdateAllSubnetCIDR) {
        return;
      }
      newSubnetCIDRAry = [];
      newSimpleSubnetCIDRAry = MC.aws.subnet.autoAssignSimpleCIDR(vpcCIDR, oldSubnetAry, oldVPCCIDR);
      if (newSimpleSubnetCIDRAry.length) {
        newSubnetCIDRAry = newSimpleSubnetCIDRAry;
      } else {
        newSubnetCIDRAry = MC.aws.subnet.autoAssignAllCIDR(vpcCIDR, subnetCount);
      }
      subnetNum = 0;
      _.each(MC.canvas_data.component, function(compObj) {
        var newCIDR;
        if (compObj.type === constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet) {
          newCIDR = newSubnetCIDRAry[subnetNum];
          MC.canvas_data.component[compObj.uid].resource.CidrBlock = newCIDR;
          MC.aws.subnet.updateAllENIIPList(compObj.uid);
          MC.canvas.update(compObj.uid, 'text', 'label', compObj.name + ' (' + newCIDR + ')');
          return subnetNum++;
        }
      });
      return null;
    };
    checkFullDefaultVPC = function() {
      var accountData, allSubnetIsDefaultForAZ, currentRegion, defaultSubnetObj, defaultVPCId;
      if (MC.canvas_data.platform !== 'default-vpc') {
        return false;
      }
      currentRegion = MC.canvas_data.region;
      accountData = MC.data.account_attribute[currentRegion];
      defaultVPCId = accountData.default_vpc;
      defaultSubnetObj = accountData.default_subnet;
      if (defaultVPCId === 'none') {
        return false;
      }
      if (!defaultSubnetObj || _.keys(defaultSubnetObj).length === 0) {
        return false;
      }
      allSubnetIsDefaultForAZ = true;
      _.each(defaultSubnetObj, function(subnetObj, azName) {
        if (subnetObj.defaultForAz !== 'true') {
          allSubnetIsDefaultForAZ = false;
        }
        if (subnetObj.vpcId !== defaultVPCId) {
          allSubnetIsDefaultForAZ = false;
        }
        if (subnetObj.state !== 'available') {
          allSubnetIsDefaultForAZ = false;
        }
        return null;
      });
      if (allSubnetIsDefaultForAZ) {
        return true;
      } else {
        return false;
      }
    };
    getSubnetForDefaultVPC = function(instanceOrEniUID) {
      var accountData, currentRegion, defaultSubnetObj, defaultVPCId, instanceAZ, instanceComp, subnetObj;
      instanceComp = MC.canvas_data.component[instanceOrEniUID];
      instanceAZ = '';
      if (instanceComp.resource.AvailabilityZone) {
        instanceAZ = instanceComp.resource.AvailabilityZone;
      } else {
        instanceAZ = instanceComp.resource.Placement.AvailabilityZone;
      }
      currentRegion = MC.canvas_data.region;
      accountData = MC.data.account_attribute[currentRegion];
      defaultVPCId = accountData.default_vpc;
      defaultSubnetObj = accountData.default_subnet;
      subnetObj = defaultSubnetObj[instanceAZ];
      return subnetObj;
    };
    getAZSubnetForDefaultVPC = function(azName) {
      var accountData, currentRegion, defaultSubnetObj, subnetObj;
      currentRegion = MC.canvas_data.region;
      accountData = MC.data.account_attribute[currentRegion];
      defaultSubnetObj = accountData.default_subnet;
      subnetObj = defaultSubnetObj[azName];
      return subnetObj;
    };
    generateComponentForDefaultVPC = function() {
      var azObjAry, azSubnetIdMap, currentComps, defaultVPCId, originComps, resType;
      resType = constant.AWS_RESOURCE_TYPE;
      originComps = MC.canvas_data.component;
      currentComps = _.extend(originComps, {});
      defaultVPCId = MC.aws.aws.checkDefaultVPC();
      azObjAry = MC.data.config[MC.canvas_data.region].zone.item;
      azSubnetIdMap = {};
      _.each(azObjAry, function(azObj) {
        var azName, resultObj, subnetId, subnetObj;
        azName = azObj.zoneName;
        resultObj = {};
        subnetObj = MC.aws.vpc.getAZSubnetForDefaultVPC(azName);
        subnetId = null;
        if (subnetObj) {
          subnetId = subnetObj.subnetId;
        } else {
          subnetId = '';
        }
        azSubnetIdMap[azName] = subnetId;
        return null;
      });
      _.each(currentComps, function(compObj) {
        var asgAZAry, asgSubnetIdAry, asgSubnetIdStr, azNameAry, compType, compUID, eniAZName, instanceAZName, subnetIdAry;
        compType = compObj.type;
        compUID = compObj.uid;
        if (compType === resType.AWS_EC2_Instance) {
          instanceAZName = compObj.resource.Placement.AvailabilityZone;
          currentComps[compUID].resource.VpcId = defaultVPCId;
          currentComps[compUID].resource.SubnetId = azSubnetIdMap[instanceAZName];
        } else if (compType === resType.AWS_VPC_NetworkInterface) {
          eniAZName = compObj.resource.AvailabilityZone;
          currentComps[compUID].resource.VpcId = defaultVPCId;
          currentComps[compUID].resource.SubnetId = azSubnetIdMap[eniAZName];
        } else if (compType === resType.AWS_ELB) {
          currentComps[compUID].resource.VpcId = defaultVPCId;
          azNameAry = MC.aws.elb.getAZAryForDefaultVPC(compUID);
          subnetIdAry = _.map(azNameAry, function(azName) {
            return azSubnetIdMap[azName];
          });
          currentComps[compUID].resource.Subnets = subnetIdAry;
        } else if (compType === resType.AWS_EC2_SecurityGroup) {
          currentComps[compUID].resource.VpcId = defaultVPCId;
        } else if (compType === resType.AWS_AutoScaling_Group) {
          asgAZAry = compObj.resource.AvailabilityZones;
          asgSubnetIdAry = _.map(asgAZAry, function(azName) {
            return azSubnetIdMap[azName];
          });
          asgSubnetIdStr = asgSubnetIdAry.join(' , ');
          currentComps[compUID].resource.VPCZoneIdentifier = asgSubnetIdStr;
        }
        return null;
      });
      return currentComps;
    };
    return {
      getVPCUID: getVPCUID,
      updateAllSubnetCIDR: updateAllSubnetCIDR,
      checkFullDefaultVPC: checkFullDefaultVPC,
      getSubnetForDefaultVPC: getSubnetForDefaultVPC,
      getAZSubnetForDefaultVPC: getAZSubnetForDefaultVPC,
      generateComponentForDefaultVPC: generateComponentForDefaultVPC
    };
  });

}).call(this);
