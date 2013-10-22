(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['constant', 'MC'], function(constant, MC) {
    var addInstanceAndAZToELB, addLCToELB, addSubnetToELB, getAZAryForDefaultVPC, getAllElbSGUID, getElbDefaultSG, getNewName, haveAssociateInAZ, init, isELBDefaultSG, removeASGFromELB, removeAllELBForInstance, removeELBDefaultSG, removeInstanceFromELB, removeSubnetFromELB, setAllELBSchemeAsInternal, updateRuleToElbSG;
    init = function(uid) {
      var allComp, defaultVPC, elbComp, newELBName, sgComp, sgRef, vpcUIDRef;
      elbComp = MC.canvas_data.component[uid];
      newELBName = MC.aws.elb.getNewName();
      MC.canvas_data.component[uid].resource.LoadBalancerName = newELBName;
      MC.canvas_data.component[uid].name = newELBName;
      MC.canvas.update(uid, 'text', 'elb_name', newELBName);
      allComp = MC.canvas_data.component;
      vpcUIDRef = elbComp.resource.VpcId;
      defaultVPC = false;
      if (MC.aws.aws.checkDefaultVPC()) {
        defaultVPC = true;
      }
      if (!vpcUIDRef && !defaultVPC) {
        MC.canvas_data.component[uid].resource.Scheme = '';
      }
      if (MC.aws.vpc.getVPCUID() || defaultVPC) {
        sgComp = $.extend(true, {}, MC.canvas.SG_JSON.data);
        sgComp.uid = MC.guid();
        sgComp.name = newELBName + '-sg';
        sgComp.resource.GroupDescription = 'Automatically created SG for load-balancer';
        sgComp.resource.GroupName = sgComp.name;
        if (vpcUIDRef) {
          sgComp.resource.VpcId = vpcUIDRef;
        }
        MC.canvas_data.component[sgComp.uid] = sgComp;
        sgRef = '@' + sgComp.uid + '.resource.GroupId';
        MC.canvas_data.component[uid].resource.SecurityGroups = [sgRef];
        MC.aws.elb.updateRuleToElbSG(uid);
        MC.aws.sg.addSGToProperty(sgComp);
      }
      return null;
    };
    getNewName = function() {
      var maxNum, namePrefix;
      maxNum = 0;
      namePrefix = 'load-balancer-';
      _.each(MC.canvas_data.component, function(compObj) {
        var compType, currentNum, elbName;
        compType = compObj.type;
        if (compType === 'AWS.ELB') {
          elbName = compObj.name;
          if (elbName.slice(0, namePrefix.length) === namePrefix) {
            currentNum = Number(elbName.slice(namePrefix.length));
            if (currentNum > maxNum) {
              maxNum = currentNum;
            }
          }
        }
        return null;
      });
      maxNum++;
      return namePrefix + maxNum;
    };
    addInstanceAndAZToELB = function(elbUID, instanceUID) {
      var addAZToElb, addInstanceToElb, alreadyLinkedSubnet, currentInstanceAZ, elbAZAry, elbAZAryLength, elbComp, elbInstanceAry, elbInstanceAryLength, i, instanceComp, instanceRef, linkedSubnet, linkedSubnetID, subnet, subnet_uid, _i, _len, _ref;
      elbComp = MC.canvas_data.component[elbUID];
      instanceComp = MC.canvas_data.component[instanceUID];
      currentInstanceAZ = instanceComp.resource.Placement.AvailabilityZone;
      instanceUID = instanceComp.uid;
      instanceRef = '@' + instanceUID + '.resource.InstanceId';
      elbInstanceAry = elbComp.resource.Instances;
      elbInstanceAryLength = elbInstanceAry.length;
      elbAZAry = elbComp.resource.AvailabilityZones;
      elbAZAryLength = elbAZAry.length;
      addInstanceToElb = true;
      _.each(elbInstanceAry, function(elem, index) {
        if (elem.InstanceId === instanceRef) {
          addInstanceToElb = false;
          return null;
        }
      });
      if (addInstanceToElb) {
        MC.canvas_data.component[elbUID].resource.Instances.push({
          InstanceId: instanceRef
        });
      }
      addAZToElb = true;
      _.each(elbAZAry, function(elem, index) {
        if (elem === currentInstanceAZ) {
          addAZToElb = false;
          return null;
        }
      });
      if (addAZToElb) {
        MC.canvas_data.component[elbUID].resource.AvailabilityZones.push(currentInstanceAZ);
      }
      subnet_uid = "@" + subnet_uid + ".resource.SubnetId";
      _ref = elbComp.resource.Subnets;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        subnet = _ref[i];
        linkedSubnetID = MC.extractID(subnet);
        linkedSubnet = MC.canvas_data.component[linkedSubnetID];
        if (linkedSubnet.resource.AvailabilityZone === currentInstanceAZ) {
          alreadyLinkedSubnet = true;
          break;
        }
      }
      if (!alreadyLinkedSubnet && instanceComp.resource.SubnetId) {
        elbComp.resource.Subnets.push(instanceComp.resource.SubnetId);
        return MC.extractID(instanceComp.resource.SubnetId);
      }
      return null;
    };
    removeInstanceFromELB = function(elbUID, instanceUID) {
      var elbComp, elbInstanceAry, elbInstanceAryLength, instanceAry, instanceComp, instanceRef, newInstanceAry;
      elbComp = MC.canvas_data.component[elbUID];
      instanceComp = MC.canvas_data.component[instanceUID];
      instanceUID = instanceComp.uid;
      instanceRef = '@' + instanceUID + '.resource.InstanceId';
      elbInstanceAry = elbComp.resource.Instances;
      elbInstanceAryLength = elbInstanceAry.length;
      instanceAry = MC.canvas_data.component[elbUID].resource.Instances;
      newInstanceAry = _.filter(instanceAry, function(value) {
        if (value.InstanceId === instanceRef) {
          return false;
        } else {
          return true;
        }
      });
      MC.canvas_data.component[elbUID].resource.Instances = newInstanceAry;
      return null;
    };
    setAllELBSchemeAsInternal = function() {
      _.each(MC.canvas_data.component, function(value, key) {
        if (value.type === 'AWS.ELB') {
          MC.canvas_data.component[key].resource.Scheme = 'internal';
          MC.canvas.update(key, 'image', 'elb_scheme', MC.canvas.IMAGE.ELB_INTERNAL_CANVAS);
        }
        return null;
      });
      return null;
    };
    addSubnetToELB = function(elb_uid, subnet_uid) {
      var az_subnet_map, elb, i, linkedSubnet, linkedSubnetID, newSubnetAZ, replacedSubnet, subnet, _i, _len, _ref;
      elb = MC.canvas_data.component[elb_uid];
      az_subnet_map = {};
      newSubnetAZ = MC.canvas_data.component[subnet_uid].resource.AvailabilityZone;
      subnet_uid = "@" + subnet_uid + ".resource.SubnetId";
      _ref = elb.resource.Subnets;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        subnet = _ref[i];
        linkedSubnetID = MC.extractID(subnet);
        linkedSubnet = MC.canvas_data.component[linkedSubnetID];
        if (linkedSubnet.resource.AvailabilityZone === newSubnetAZ) {
          replacedSubnet = linkedSubnetID;
          elb.resource.Subnets[i] = subnet_uid;
        }
      }
      if (!replacedSubnet) {
        elb.resource.Subnets.push(subnet_uid);
        elb.resource.AvailabilityZones.push(newSubnetAZ);
      }
      return replacedSubnet;
    };
    removeSubnetFromELB = function(elb_uid, subnet_uid) {
      var az, az_arr, az_map, elb, i, subnet, _i, _j, _len, _len1, _ref, _ref1;
      elb = MC.canvas_data.component[elb_uid];
      _ref = elb.resource.Subnets;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        subnet = _ref[i];
        if (subnet.indexOf(subnet_uid) !== -1) {
          elb.resource.Subnets.splice(i, 1);
          break;
        }
      }
      az_map = {};
      az_arr = [];
      _ref1 = elb.resource.Subnets;
      for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
        subnet = _ref1[i];
        az = MC.canvas_data.component[MC.extractID(subnet)].resource.AvailabilityZone;
        if (az_map[az]) {
          continue;
        }
        az_map[az] = true;
        az_arr.push(az);
      }
      elb.resource.AvailabilityZones = az_arr;
      return null;
    };
    addLCToELB = function(elb_uid, lc_uid) {
      var asg, az, azs, comp, components, elb_res, linkedSubnets, sb, subnets, uid, _i, _j, _len, _len1, _ref;
      components = MC.canvas_data.component;
      for (uid in components) {
        comp = components[uid];
        if (comp.type === constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group) {
          if (comp.resource.LaunchConfigurationName.indexOf(lc_uid) !== -1) {
            asg = comp;
            break;
          }
        }
      }
      if (!asg) {
        return [];
      }
      if (asg.resource.LoadBalancerNames.join(" ").indexOf(elb_uid) === -1) {
        asg.resource.LoadBalancerNames.push("@" + elb_uid + ".resource.LoadBalancerName");
      }
      if (asg.resource.VPCZoneIdentifier.length) {
        subnets = asg.resource.VPCZoneIdentifier.split(",");
        subnets = _.map(subnets, MC.extractID);
      } else {
        subnets = [];
      }
      azs = {};
      for (_i = 0, _len = subnets.length; _i < _len; _i++) {
        sb = subnets[_i];
        if (sb && components[sb]) {
          azs[components[sb].resource.AvailabilityZone] = sb;
        }
      }
      elb_res = components[elb_uid].resource;
      _ref = elb_res.AvailabilityZones;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        az = _ref[_j];
        delete azs[az];
      }
      subnets = [];
      linkedSubnets = elb_res.Subnets.join(" ");
      for (az in azs) {
        sb = azs[az];
        elb_res.AvailabilityZones.push(az);
        if (linkedSubnets.indexOf(sb) === -1) {
          subnets.push(sb);
          elb_res.Subnets.push("@" + sb + ".resource.SubnetId");
        }
      }
      return subnets;
    };
    removeASGFromELB = function(elb_uid, asg_uid) {
      var asg, names;
      asg = MC.canvas_data.component[asg_uid];
      names = asg.resource.LoadBalancerNames.join(" ").replace("@" + elb_uid + ".resource.LoadBalancerName", "");
      asg.resource.LoadBalancerNames = names.length === 0 ? [] : names.split(" ");
      return null;
    };
    updateRuleToElbSG = function(elbUID) {
      var elbComp, elbDefaultSG, elbDefaultSGInboundRuleAry, elbDefaultSGUID, elbListenerAry, listenerAry;
      if (!MC.aws.vpc.getVPCUID()) {
        return;
      }
      elbComp = MC.canvas_data.component[elbUID];
      elbListenerAry = elbComp.resource.ListenerDescriptions;
      listenerAry = [];
      _.each(elbListenerAry, function(listenerObj) {
        var port;
        port = listenerObj.Listener.LoadBalancerPort;
        listenerAry.push({
          protocol: 'tcp',
          port: port
        });
        return null;
      });
      listenerAry = _.uniq(listenerAry);
      elbDefaultSG = MC.aws.elb.getElbDefaultSG(elbUID);
      elbDefaultSGUID = elbDefaultSG.uid;
      elbDefaultSGInboundRuleAry = elbDefaultSG.resource.IpPermissions;
      _.each(listenerAry, function(listenerObj) {
        var addListenerToRule, removeListenerToRule;
        addListenerToRule = true;
        removeListenerToRule = true;
        _.each(elbDefaultSGInboundRuleAry, function(ruleObj) {
          var port, protocol;
          protocol = 'tcp';
          port = ruleObj.FromPort;
          if (listenerObj.protocol === protocol && listenerObj.port === port) {
            addListenerToRule = false;
            return;
          }
          return null;
        });
        if (addListenerToRule) {
          elbDefaultSGInboundRuleAry.push({
            FromPort: listenerObj.port,
            ToPort: listenerObj.port,
            IpProtocol: listenerObj.protocol,
            IpRanges: '0.0.0.0/0',
            Groups: [
              {
                GroupId: '',
                GroupName: '',
                UserId: ''
              }
            ]
          });
        }
        return null;
      });
      elbDefaultSGInboundRuleAry = _.filter(elbDefaultSGInboundRuleAry, function(ruleObj) {
        var isInListener, port, protocol;
        protocol = ruleObj.IpProtocol;
        port = ruleObj.FromPort;
        isInListener = false;
        _.each(listenerAry, function(listenerObj) {
          if (listenerObj.protocol === protocol && listenerObj.port === port) {
            isInListener = true;
          }
          return null;
        });
        return isInListener;
      });
      return MC.canvas_data.component[elbDefaultSGUID].resource.IpPermissions = elbDefaultSGInboundRuleAry;
    };
    getElbDefaultSG = function(elbUID) {
      var allComp, elbComp, elbName, elbSGName, elbSGUID;
      elbComp = MC.canvas_data.component[elbUID];
      if (!elbComp) {
        return null;
      }
      elbName = elbComp.resource.LoadBalancerName;
      elbSGName = elbName + '-sg';
      elbSGUID = '';
      allComp = MC.canvas_data.component;
      _.each(allComp, function(compObj) {
        if (compObj.name === elbSGName) {
          elbSGUID = compObj.uid;
        }
      });
      return MC.canvas_data.component[elbSGUID];
    };
    getAllElbSGUID = function() {
      var elbSGUIDAry;
      elbSGUIDAry = [];
      _.each(MC.canvas_data.component, function(compObj) {
        var compType, elbSGObj;
        compType = compObj.type;
        if (compType === 'AWS.ELB') {
          elbSGObj = MC.aws.elb.getElbDefaultSG(compObj.uid);
          if (elbSGObj) {
            elbSGUIDAry.push(elbSGObj.uid);
          }
        }
        return null;
      });
      return elbSGUIDAry;
    };
    removeELBDefaultSG = function(elbUID) {
      var elbSGObj;
      elbSGObj = MC.aws.elb.getElbDefaultSG(elbUID);
      if (elbSGObj) {
        return delete MC.canvas_data.component[elbSGObj.uid];
      }
    };
    isELBDefaultSG = function(sgUID) {
      var result;
      result = false;
      _.each(MC.canvas_data.component, function(compObj) {
        var compType, elbSGObj;
        compType = compObj.type;
        if (compType === 'AWS.ELB') {
          elbSGObj = MC.aws.elb.getElbDefaultSG(compObj.uid);
          if (elbSGObj && elbSGObj.uid === sgUID) {
            result = true;
          }
        }
        return null;
      });
      return result;
    };
    removeAllELBForInstance = function(instanceUID) {
      var originInstanceUIDRef;
      originInstanceUIDRef = '@' + instanceUID + '.resource.InstanceId';
      _.each(MC.canvas_data.component, function(compObj) {
        var compType, instanceAry, newInstanceAry;
        compType = compObj.type;
        if (compType === 'AWS.ELB') {
          instanceAry = compObj.resource.Instances;
          newInstanceAry = _.filter(instanceAry, function(instanceObj) {
            var instanceRef;
            instanceRef = instanceObj.InstanceId;
            if (instanceRef === originInstanceUIDRef) {
              return false;
            } else {
              return true;
            }
          });
          MC.canvas_data.component[compObj.uid].resource.Instances = newInstanceAry;
        }
        return null;
      });
      return null;
    };
    haveAssociateInAZ = function(elbUID, azName) {
      var elbAZs, elbComp, elbInstances, haveAssociate;
      elbComp = MC.canvas_data.component[elbUID];
      elbInstances = elbComp.resource.Instances;
      elbAZs = elbComp.resource.AvailabilityZones;
      haveAssociate = false;
      _.each(elbInstances, function(instanceObj) {
        var instanceAZ, instanceComp, instanceUID;
        instanceUID = instanceObj.InstanceId.slice(1).split('.')[0];
        instanceComp = MC.canvas_data.component[instanceUID];
        instanceAZ = instanceComp.resource.Placement.AvailabilityZone;
        if (instanceAZ === azName) {
          return haveAssociate = true;
        }
      });
      return haveAssociate;
    };
    getAZAryForDefaultVPC = function(elbUID) {
      var azNameAry, elbComp, elbInstances;
      elbComp = MC.canvas_data.component[elbUID];
      elbInstances = elbComp.resource.Instances;
      azNameAry = [];
      _.each(elbInstances, function(instanceRefObj) {
        var instanceAZName, instanceRef, instanceUID;
        instanceRef = instanceRefObj.InstanceId;
        instanceUID = instanceRef.slice(1).split('.')[0];
        instanceAZName = MC.canvas_data.component[instanceUID].resource.Placement.AvailabilityZone;
        if (!(__indexOf.call(azNameAry, instanceAZName) >= 0)) {
          azNameAry.push(instanceAZName);
        }
        return null;
      });
      return azNameAry;
    };
    return {
      init: init,
      addInstanceAndAZToELB: addInstanceAndAZToELB,
      removeInstanceFromELB: removeInstanceFromELB,
      setAllELBSchemeAsInternal: setAllELBSchemeAsInternal,
      addSubnetToELB: addSubnetToELB,
      removeSubnetFromELB: removeSubnetFromELB,
      addLCToELB: addLCToELB,
      removeASGFromELB: removeASGFromELB,
      getNewName: getNewName,
      getElbDefaultSG: getElbDefaultSG,
      updateRuleToElbSG: updateRuleToElbSG,
      getAllElbSGUID: getAllElbSGUID,
      removeELBDefaultSG: removeELBDefaultSG,
      isELBDefaultSG: isELBDefaultSG,
      removeAllELBForInstance: removeAllELBForInstance,
      haveAssociateInAZ: haveAssociateInAZ,
      getAZAryForDefaultVPC: getAZAryForDefaultVPC
    };
  });

}).call(this);
