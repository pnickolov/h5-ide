(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['MC'], function(MC) {
    var displayENINumber, generateIPList, getAllOtherIPInCIDR, getAvailableIPInCIDR, getENIDivIPAry, getENIMaxIPNum, getInstanceDefaultENI, getSubnetComp, getSubnetNeedIPCount, reduceAllENIIPList, reduceIPNumByInstanceType, saveIPList;
    getAvailableIPInCIDR = function(ipCidr, filter, maxNeedIPCount) {
      var allIPAry, availableIPCount, cutAry, ipAddr, ipAddrAry, ipAddrBinAry, ipAddrBinPrefixStr, ipAddrBinStr, ipAddrBinStrSuffixMax, ipAddrBinStrSuffixMin, ipAddrNumSuffixMax, ipAddrNumSuffixMin, prefix, suffix, _addZeroToLeftStr, _i, _ref, _results;
      _addZeroToLeftStr = function(str, n) {
        var count, strAry, _i, _results;
        count = n - str.length + 1;
        strAry = _.map((function() {
          _results = [];
          for (var _i = 1; 1 <= count ? _i < count : _i > count; 1 <= count ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this), function() {
          return '0';
        });
        return str = strAry.join('') + str;
      };
      cutAry = ipCidr.split('/');
      ipAddr = cutAry[0];
      suffix = Number(cutAry[1]);
      prefix = 32 - suffix;
      ipAddrAry = ipAddr.split('.');
      ipAddrBinAry = _.map(ipAddrAry, function(value) {
        return _addZeroToLeftStr(parseInt(value).toString(2), 8);
      });
      ipAddrBinStr = ipAddrBinAry.join('');
      ipAddrBinPrefixStr = ipAddrBinStr.slice(0, suffix);
      ipAddrBinStrSuffixMin = ipAddrBinStr.slice(suffix).replace(/1/g, '0');
      ipAddrBinStrSuffixMax = ipAddrBinStrSuffixMin.replace(/0/g, '1');
      ipAddrNumSuffixMin = parseInt(ipAddrBinStrSuffixMin, 2);
      ipAddrNumSuffixMax = parseInt(ipAddrBinStrSuffixMax, 2);
      allIPAry = [];
      availableIPCount = 0;
      _.each((function() {
        _results = [];
        for (var _i = ipAddrNumSuffixMin, _ref = ipAddrNumSuffixMax + 1; ipAddrNumSuffixMin <= _ref ? _i < _ref : _i > _ref; ipAddrNumSuffixMin <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this), function(value) {
        var isAvailableIP, newIPAry, newIPBinStr, newIPObj, newIPStr;
        newIPBinStr = ipAddrBinPrefixStr + _addZeroToLeftStr(value.toString(2), prefix);
        isAvailableIP = true;
        newIPAry = _.map([0, 8, 16, 24], function(value) {
          var newIPNum;
          newIPNum = parseInt(newIPBinStr.slice(value, value + 8), 2);
          if (value === 24 && (newIPNum === 0 || newIPNum === 1 || newIPNum === 2 || newIPNum === 3 || newIPNum === 255)) {
            isAvailableIP = false;
          }
          return newIPNum;
        });
        newIPStr = newIPAry.join('.');
        if (__indexOf.call(filter, newIPStr) >= 0) {
          isAvailableIP = false;
        }
        newIPObj = {
          ip: newIPStr,
          available: isAvailableIP
        };
        allIPAry.push(newIPObj);
        if (isAvailableIP) {
          availableIPCount++;
        }
        if (availableIPCount > maxNeedIPCount) {
          return false;
        }
        return null;
      });
      console.log('availableIPCount: ' + availableIPCount);
      return allIPAry;
    };
    getAllOtherIPInCIDR = function(subnetUIDRefOrAZ, rejectEniUID) {
      var allCompAry, allOtherIPAry, defaultVPCId;
      defaultVPCId = MC.aws.aws.checkDefaultVPC();
      allCompAry = MC.canvas_data.component;
      allOtherIPAry = [];
      _.each(allCompAry, function(compObj) {
        var currentAZName, currentSubnetUIDRef, privateIpAddressSet;
        if (compObj.type === 'AWS.VPC.NetworkInterface') {
          if (compObj.uid === rejectEniUID) {
            return;
          }
          currentSubnetUIDRef = compObj.resource.SubnetId;
          currentAZName = compObj.resource.AvailabilityZone;
          if ((!defaultVPCId && currentSubnetUIDRef === subnetUIDRefOrAZ) || (defaultVPCId && currentAZName === subnetUIDRefOrAZ)) {
            privateIpAddressSet = compObj.resource.PrivateIpAddressSet;
            _.each(privateIpAddressSet, function(value) {
              allOtherIPAry.push(value.PrivateIpAddress);
              return null;
            });
          }
        }
        return null;
      });
      return allOtherIPAry;
    };
    saveIPList = function(eniUID, ipList) {
      var eniComp, instanceUIDRef, primary, privateIpAddressSet;
      eniComp = MC.canvas_data.component[eniUID];
      instanceUIDRef = eniComp.resource.Attachment.InstanceId;
      privateIpAddressSet = [];
      primary = true;
      _.each(ipList, function(ipObj) {
        var auto, eip, instanceId, ip, privateIpAddressObj;
        ip = ipObj.ip;
        eip = ipObj.eip;
        auto = ipObj.auto;
        instanceId = '';
        if (eip) {
          instanceId = instanceUIDRef;
        }
        privateIpAddressObj = {
          Association: {
            IpOwnerId: '',
            AssociationID: '',
            InstanceId: instanceId,
            PublicDnsName: '',
            AllocationID: '',
            PublicIp: ''
          },
          PrivateIpAddress: ip,
          AutoAssign: auto,
          Primary: primary
        };
        primary = false;
        privateIpAddressSet.push(privateIpAddressObj);
        return null;
      });
      return MC.canvas_data.component[eniUID].resource.PrivateIpAddressSet = privateIpAddressSet;
    };
    generateIPList = function(eniUID, inputIPAry) {
      var allOtherIPAry, assignNum, assignedIPAry, azName, currentAvailableIPAry, currentEniComp, defaultVPCId, ipFilterAry, needAutoAssignIPCount, needIPCount, realIPAry, rejectEniUID, selfSetIPAry, subnetCidr, subnetComp, subnetId, subnetObj, subnetUIDRef;
      currentEniComp = MC.canvas_data.component[eniUID];
      rejectEniUID = eniUID;
      subnetUIDRef = '';
      allOtherIPAry = [];
      defaultVPCId = MC.aws.aws.checkDefaultVPC();
      azName = '';
      if (defaultVPCId) {
        azName = currentEniComp.resource.AvailabilityZone;
        allOtherIPAry = MC.aws.eni.getAllOtherIPInCIDR(azName, rejectEniUID);
      } else {
        subnetUIDRef = currentEniComp.resource.SubnetId;
        allOtherIPAry = MC.aws.eni.getAllOtherIPInCIDR(subnetUIDRef, rejectEniUID);
      }
      needAutoAssignIPCount = 0;
      selfSetIPAry = [];
      _.each(inputIPAry, function(ipObj) {
        var ipAddr;
        ipAddr = ipObj.ip;
        if (ipAddr.slice(ipAddr.length - 1) !== 'x') {
          return selfSetIPAry.push(ipObj.ip);
        } else {
          return needAutoAssignIPCount++;
        }
      });
      ipFilterAry = allOtherIPAry.concat(selfSetIPAry);
      subnetCidr = '';
      if (defaultVPCId) {
        subnetObj = MC.aws.vpc.getAZSubnetForDefaultVPC(azName);
        subnetCidr = subnetObj.cidrBlock;
      } else {
        subnetId = subnetUIDRef.slice(1).split('.')[0];
        subnetComp = MC.canvas_data.component[subnetId];
        subnetCidr = subnetComp.resource.CidrBlock;
      }
      needIPCount = 0;
      if (defaultVPCId) {
        needIPCount = MC.aws.eni.getSubnetNeedIPCount(azName);
      } else {
        needIPCount = MC.aws.eni.getSubnetNeedIPCount(subnetId);
      }
      currentAvailableIPAry = MC.aws.eni.getAvailableIPInCIDR(subnetCidr, ipFilterAry, needIPCount);
      assignedIPAry = [];
      _.each(currentAvailableIPAry, function(newIPObj) {
        if (needAutoAssignIPCount === 0) {
          return false;
        }
        if (newIPObj.available) {
          needAutoAssignIPCount--;
          return assignedIPAry.push(newIPObj.ip);
        }
      });
      realIPAry = [];
      assignNum = 0;
      _.each(inputIPAry, function(ipObj) {
        var assignIP, haveEIP, ipAddr;
        ipAddr = ipObj.ip;
        haveEIP = ipObj.eip;
        if (ipAddr.slice(ipAddr.length - 1) === 'x') {
          assignIP = assignedIPAry[assignNum++];
          realIPAry.push({
            ip: assignIP,
            eip: haveEIP,
            auto: true
          });
        } else {
          realIPAry.push({
            ip: ipAddr,
            eip: haveEIP,
            auto: false
          });
        }
        return null;
      });
      return realIPAry;
    };
    getInstanceDefaultENI = function(instanceUID) {
      var eniComp;
      eniComp = null;
      _.each(MC.canvas_data.component, function(compObj) {
        if (compObj.type === 'AWS.VPC.NetworkInterface' && compObj.resource.Attachment.DeviceIndex === '0' && compObj.resource.Attachment.InstanceId === ('@' + instanceUID + '.resource.InstanceId')) {
          eniComp = compObj;
          return;
        }
        return null;
      });
      return eniComp;
    };
    getENIDivIPAry = function(subnetCIDR, ipAddr) {
      var ipAddrAry, resultPrefix, resultSuffix, suffix;
      suffix = Number(subnetCIDR.split('/')[1]);
      ipAddrAry = ipAddr.split('.');
      resultPrefix = '';
      resultSuffix = '';
      if (suffix > 23) {
        resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.' + ipAddrAry[2] + '.';
        resultSuffix = ipAddrAry[3];
      } else {
        resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.';
        resultSuffix = ipAddrAry[2] + '.' + ipAddrAry[3];
      }
      return [resultPrefix, resultSuffix];
    };
    getSubnetComp = function(eniUID) {
      var eniComp, subnetUID, subnetUIDRef;
      eniComp = MC.canvas_data.component[eniUID];
      subnetUIDRef = eniComp.resource.SubnetId;
      subnetUID = subnetUIDRef.slice(1).split('.')[0];
      return MC.canvas_data.component[subnetUID];
    };
    getSubnetNeedIPCount = function(subnetUidOrAZ) {
      var azName, defaultVPC, needIPCount, subnetRef;
      defaultVPC = false;
      if (MC.aws.aws.checkDefaultVPC()) {
        defaultVPC = true;
      }
      needIPCount = 0;
      subnetRef = '';
      azName = '';
      if (defaultVPC) {
        azName = subnetUidOrAZ;
      } else {
        subnetRef = '@' + subnetUidOrAZ + '.resource.SubnetId';
      }
      _.each(MC.canvas_data.component, function(compObj) {
        if (compObj.type === 'AWS.VPC.NetworkInterface') {
          if ((!defaultVPC && compObj.resource.SubnetId === subnetRef) || (defaultVPC && compObj.resource.AvailabilityZone === azName)) {
            needIPCount += compObj.resource.PrivateIpAddressSet.length;
          }
        }
        return null;
      });
      return needIPCount;
    };
    displayENINumber = function(uid, visible) {
      return MC.canvas.display(uid, 'eni-number-group', visible);
    };
    getENIMaxIPNum = function(eniOrInstanceUID) {
      var eniComp, eniMaxIPNum, instanceComp, instanceType, instanceTypeAry, instanceUID, instanceUIDRef, typeENINumMap;
      eniComp = MC.canvas_data.component[eniOrInstanceUID];
      if (!eniComp) {
        return 0;
      }
      instanceUID = '';
      if (eniComp.type === 'AWS.VPC.NetworkInterface') {
        instanceUIDRef = eniComp.resource.Attachment.InstanceId;
        if (!instanceUIDRef) {
          return 0;
        }
        instanceUID = instanceUIDRef.split('.')[0].slice(1);
      } else {
        instanceUID = eniOrInstanceUID;
      }
      instanceComp = MC.canvas_data.component[instanceUID];
      instanceType = instanceComp.resource.InstanceType;
      instanceTypeAry = instanceType.split('.');
      if (!(instanceTypeAry[0] && instanceTypeAry[1])) {
        return 0;
      }
      typeENINumMap = MC.data.config[MC.canvas_data.region].instance_type;
      if (!typeENINumMap) {
        return 0;
      }
      eniMaxIPNum = typeENINumMap[instanceTypeAry[0]][instanceTypeAry[1]].ip_per_eni;
      if (!eniMaxIPNum) {
        return 0;
      }
      return eniMaxIPNum;
    };
    reduceIPNumByInstanceType = function(eniOrInstanceUID) {
      var currentENIMaxIPNum, defaultENIComp, eniComp, eniUID, i, ipsAry, newIpsAry;
      currentENIMaxIPNum = MC.aws.eni.getENIMaxIPNum(eniOrInstanceUID);
      eniComp = MC.canvas_data.component[eniOrInstanceUID];
      if (!eniComp) {
        return;
      }
      eniUID = '';
      if (eniComp.type === 'AWS.VPC.NetworkInterface') {
        eniUID = eniComp.uid;
        ipsAry = eniComp.resource.PrivateIpAddressSet;
      } else {
        defaultENIComp = MC.aws.eni.getInstanceDefaultENI(eniOrInstanceUID);
        eniUID = defaultENIComp.uid;
        ipsAry = defaultENIComp.resource.PrivateIpAddressSet;
      }
      i = 0;
      newIpsAry = _.filter(ipsAry, function(ipObj) {
        i++;
        if (i > currentENIMaxIPNum && currentENIMaxIPNum !== 0) {
          return false;
        } else {
          return true;
        }
      });
      return MC.canvas_data.component[eniUID].resource.PrivateIpAddressSet = newIpsAry;
    };
    reduceAllENIIPList = function(instanceUID) {
      return _.each(MC.canvas_data.component, function(compObj) {
        var eniInstanceUID, instanceUIDRef;
        if (compObj.type === 'AWS.VPC.NetworkInterface') {
          instanceUIDRef = compObj.resource.Attachment.InstanceId;
          if (!instanceUIDRef) {
            return;
          }
          eniInstanceUID = instanceUIDRef.split('.')[0].slice(1);
          if (eniInstanceUID === instanceUID) {
            MC.aws.eni.reduceIPNumByInstanceType(compObj.uid);
          }
        }
        return null;
      });
    };
    return {
      getAvailableIPInCIDR: getAvailableIPInCIDR,
      getAllOtherIPInCIDR: getAllOtherIPInCIDR,
      saveIPList: saveIPList,
      generateIPList: generateIPList,
      getInstanceDefaultENI: getInstanceDefaultENI,
      getENIDivIPAry: getENIDivIPAry,
      getSubnetComp: getSubnetComp,
      getSubnetNeedIPCount: getSubnetNeedIPCount,
      displayENINumber: displayENINumber,
      getENIMaxIPNum: getENIMaxIPNum,
      reduceIPNumByInstanceType: reduceIPNumByInstanceType,
      reduceAllENIIPList: reduceAllENIIPList
    };
  });

}).call(this);
