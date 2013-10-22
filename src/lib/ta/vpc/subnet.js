(function() {
  define(['MC'], function(MC) {
    var autoAssignAllCIDR, autoAssignSimpleCIDR, canDeleteSubnetToELBConnection, genCIDRDivAry, genCIDRPrefixSuffix, generateCIDRPossibile, getVPC, isInVPCCIDR, isSubnetConflict, isSubnetConflictInVPC, updateAllENIIPList, _addZeroToLeftStr, _addZeroToRightStr, _getCidrBinStr;
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
    _addZeroToRightStr = function(str, n) {
      var count, strAry, _i, _results;
      count = n - str.length + 1;
      strAry = _.map((function() {
        _results = [];
        for (var _i = 1; 1 <= count ? _i < count : _i > count; 1 <= count ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this), function() {
        return '0';
      });
      return str = str + strAry.join('');
    };
    _getCidrBinStr = function(ipCidr) {
      var cutAry, ipAddr, ipAddrAry, ipAddrBinAry, prefix, suffix;
      cutAry = ipCidr.split('/');
      ipAddr = cutAry[0];
      suffix = Number(cutAry[1]);
      prefix = 32 - suffix;
      ipAddrAry = ipAddr.split('.');
      ipAddrBinAry = _.map(ipAddrAry, function(value) {
        return _addZeroToLeftStr(parseInt(value).toString(2), 8);
      });
      return ipAddrBinAry.join('');
    };
    genCIDRPrefixSuffix = function(subnetCIDR) {
      var cutAry, ipAddr, ipAddrAry, resultPrefix, resultSuffix, suffix;
      cutAry = subnetCIDR.split('/');
      ipAddr = cutAry[0];
      suffix = Number(cutAry[1]);
      ipAddrAry = ipAddr.split('.');
      resultPrefix = '';
      resultSuffix = '';
      if (suffix > 23) {
        resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.' + ipAddrAry[2] + '.';
        resultSuffix = 'x';
      } else {
        resultPrefix = ipAddrAry[0] + '.' + ipAddrAry[1] + '.';
        resultSuffix = 'x.x';
      }
      return [resultPrefix, resultSuffix];
    };
    genCIDRDivAry = function(vpcCIDR, subnetCIDR) {
      var resultPrefix, resultSuffix, subnetAddrAry, subnetIPAry, subnetSuffix, vpcSuffix;
      vpcSuffix = Number(vpcCIDR.split('/')[1]);
      subnetIPAry = subnetCIDR.split('/');
      subnetSuffix = Number(subnetIPAry[1]);
      subnetAddrAry = subnetIPAry[0].split('.');
      resultPrefix = '';
      resultSuffix = '';
      if (vpcSuffix > 23) {
        resultPrefix = subnetAddrAry[0] + '.' + subnetAddrAry[1] + '.' + subnetAddrAry[2] + '.';
        resultSuffix = subnetAddrAry[3] + '/' + subnetSuffix;
      } else {
        resultPrefix = subnetAddrAry[0] + '.' + subnetAddrAry[1] + '.';
        resultSuffix = subnetAddrAry[2] + '.' + subnetAddrAry[3] + '/' + subnetSuffix;
      }
      return [resultPrefix, resultSuffix];
    };
    isSubnetConflict = function(ipCidr1, ipCidr2) {
      var ipCidr1BinStr, ipCidr1Suffix, ipCidr2BinStr, ipCidr2Suffix, minIpCidrSuffix;
      ipCidr1BinStr = _getCidrBinStr(ipCidr1);
      ipCidr2BinStr = _getCidrBinStr(ipCidr2);
      ipCidr1Suffix = Number(ipCidr1.split('/')[1]);
      ipCidr2Suffix = Number(ipCidr2.split('/')[1]);
      minIpCidrSuffix = ipCidr1Suffix;
      if (ipCidr1Suffix > ipCidr2Suffix) {
        minIpCidrSuffix = ipCidr2Suffix;
      }
      if (ipCidr1BinStr.slice(0, minIpCidrSuffix) === ipCidr2BinStr.slice(0, minIpCidrSuffix) && minIpCidrSuffix !== 0) {
        return true;
      } else {
        return false;
      }
    };
    isSubnetConflictInVPC = function(subnetUID, originSubnetCIDR) {
      var isHaveConflict, subnetCIDR, vpcComp, vpcUID;
      subnetCIDR = '';
      if (originSubnetCIDR) {
        subnetCIDR = originSubnetCIDR;
      } else {
        subnetCIDR = MC.canvas_data.component[subnetUID].resource.CidrBlock;
      }
      vpcComp = MC.aws.subnet.getVPC(subnetUID);
      vpcUID = vpcComp.uid;
      isHaveConflict = false;
      _.each(MC.canvas_data.component, function(compObj) {
        var currentSubnetCIDR, currentSubnetUID, subnetVPCUID;
        if (compObj.type === 'AWS.VPC.Subnet') {
          subnetVPCUID = compObj.resource.VpcId.split('.')[0].slice(1);
          currentSubnetUID = compObj.uid;
          currentSubnetCIDR = compObj.resource.CidrBlock;
          if (subnetVPCUID === vpcUID && subnetUID !== currentSubnetUID) {
            if (isSubnetConflict(subnetCIDR, currentSubnetCIDR)) {
              isHaveConflict = true;
              return false;
            }
          }
        }
        return null;
      });
      return isHaveConflict;
    };
    isInVPCCIDR = function(vpcCIDR, subnetCIDR) {
      var subnetCIDRSuffix, vpcCIDRSuffix;
      if (MC.aws.subnet.isSubnetConflict(vpcCIDR, subnetCIDR)) {
        vpcCIDRSuffix = Number(vpcCIDR.split('/')[1]);
        subnetCIDRSuffix = Number(subnetCIDR.split('/')[1]);
        if (subnetCIDRSuffix < vpcCIDRSuffix) {
          return false;
        } else {
          return true;
        }
      } else {
        return false;
      }
    };
    autoAssignAllCIDR = function(vpcCIDR, subnetCount) {
      var needBinNum, newSubnetAry, newSubnetSuffix, vpcIPBinLeftStr, vpcIPBinStr, vpcIPSuffix, _i, _results;
      needBinNum = Math.ceil((Math.log(subnetCount)) / (Math.log(2)));
      vpcIPSuffix = Number(vpcCIDR.split('/')[1]);
      vpcIPBinStr = _getCidrBinStr(vpcCIDR);
      vpcIPBinLeftStr = vpcIPBinStr.slice(0, vpcIPSuffix);
      newSubnetSuffix = vpcIPSuffix + needBinNum;
      newSubnetAry = [];
      _.each((function() {
        _results = [];
        for (var _i = 0; 0 <= subnetCount ? _i < subnetCount : _i > subnetCount; 0 <= subnetCount ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this), function(i) {
        var binSeq, newIPAry, newIPStr, newSubnetBinStr, newSubnetStr;
        binSeq = _addZeroToLeftStr(i.toString(2), needBinNum);
        newSubnetBinStr = _addZeroToRightStr(vpcIPBinLeftStr + binSeq, 32);
        newIPAry = _.map([0, 8, 16, 24], function(value) {
          return parseInt(newSubnetBinStr.slice(value, value + 8), 2);
        });
        newIPStr = newIPAry.join('.');
        newSubnetStr = newIPStr + '/' + newSubnetSuffix;
        newSubnetAry.push(newSubnetStr);
        return null;
      });
      return newSubnetAry;
    };
    autoAssignSimpleCIDR = function(newVPCCIDR, oldSubnetAry, oldVPCCIDR) {
      var newSubnetAry, oldVPCCIDRSuffix, vpcCIDRAry, vpcCIDRIPStr, vpcCIDRSuffix, vpcIP1, vpcIP2, vpcIP3, vpcIPAry;
      newSubnetAry = [];
      vpcCIDRAry = newVPCCIDR.split('/');
      vpcCIDRIPStr = vpcCIDRAry[0];
      vpcCIDRSuffix = Number(vpcCIDRAry[1]);
      vpcIPAry = vpcCIDRIPStr.split('.');
      oldVPCCIDRSuffix = Number(oldVPCCIDR.split('/')[1]);
      if (vpcCIDRSuffix === 16 || (vpcCIDRSuffix === 24 && oldVPCCIDRSuffix === vpcCIDRSuffix)) {
        vpcIP1 = vpcIPAry[0];
        vpcIP2 = vpcIPAry[1];
        vpcIP3 = vpcIPAry[2];
        _.each(oldSubnetAry, function(subnetCIDR) {
          var newSubnetCIDR, subnetCIDRAry, subnetCIDRIPStr, subnetCIDRSuffix, subnetIPAry;
          subnetCIDRAry = subnetCIDR.split('/');
          subnetCIDRIPStr = subnetCIDRAry[0];
          subnetCIDRSuffix = Number(subnetCIDRAry[1]);
          subnetIPAry = subnetCIDRIPStr.split('.');
          subnetIPAry[0] = vpcIP1;
          subnetIPAry[1] = vpcIP2;
          if (vpcCIDRSuffix === 24) {
            subnetIPAry[2] = vpcIP3;
          }
          newSubnetCIDR = subnetIPAry.join('.') + '/' + subnetCIDRSuffix;
          newSubnetAry.push(newSubnetCIDR);
          return null;
        });
      }
      return newSubnetAry;
    };
    getVPC = function(subnetUID) {
      var subnetComp, vpcUID;
      subnetComp = MC.canvas_data.component[subnetUID];
      vpcUID = subnetComp.resource.VpcId.slice(1).split('.')[0];
      if (vpcUID) {
        return MC.canvas_data.component[vpcUID];
      } else {
        return null;
      }
    };
    updateAllENIIPList = function(subnetUidOrAZ) {
      var assignedIPAry, azName, currentAvailableIPAry, defaultVPC, i, needIPCount, subnetCIDR, subnetComp, subnetObj, subnetRef;
      defaultVPC = false;
      if (MC.aws.aws.checkDefaultVPC()) {
        defaultVPC = true;
      }
      needIPCount = 0;
      subnetCIDR = '';
      azName = '';
      subnetRef = '';
      if (defaultVPC) {
        azName = subnetUidOrAZ;
        subnetObj = MC.aws.vpc.getAZSubnetForDefaultVPC(azName);
        subnetCIDR = subnetObj.cidrBlock;
        needIPCount = MC.aws.eni.getSubnetNeedIPCount(azName);
      } else {
        subnetComp = MC.canvas_data.component[subnetUidOrAZ];
        if (!subnetComp) {
          return;
        }
        subnetRef = '@' + subnetComp.uid + '.resource.SubnetId';
        subnetCIDR = subnetComp.resource.CidrBlock;
        needIPCount = MC.aws.eni.getSubnetNeedIPCount(subnetComp.uid);
      }
      currentAvailableIPAry = MC.aws.eni.getAvailableIPInCIDR(subnetCIDR, [], needIPCount);
      assignedIPAry = [];
      _.each(currentAvailableIPAry, function(newIPObj) {
        if (needIPCount === 0) {
          return false;
        }
        if (newIPObj.available) {
          needIPCount--;
          return assignedIPAry.push(newIPObj.ip);
        }
      });
      i = 0;
      _.each(MC.canvas_data.component, function(compObj) {
        var newPrivateIpAddressSet;
        if ((!defaultVPC && compObj.resource.SubnetId === subnetRef) || (defaultVPC && compObj.resource.AvailabilityZone === azName)) {
          newPrivateIpAddressSet = _.map(compObj.resource.PrivateIpAddressSet, function(ipObj) {
            ipObj.PrivateIpAddress = assignedIPAry[i++];
            ipObj.AutoAssign = true;
            return ipObj;
          });
          MC.canvas_data.component[compObj.uid].resource.PrivateIpAddressSet = newPrivateIpAddressSet;
        }
        return null;
      });
      return null;
    };
    canDeleteSubnetToELBConnection = function(elbUID, subnetUID) {
      var azAry, azSubnetNumMap, currentAZ, elbComp, instanceRefAry, isCanDelete, subnetAry, subnetRefAry;
      elbComp = MC.canvas_data.component[elbUID];
      instanceRefAry = elbComp.resource.Instances;
      subnetRefAry = elbComp.resource.Subnets;
      isCanDelete = true;
      subnetAry = [];
      _.each(MC.canvas_data.component, function(comp) {
        if (comp.type === 'AWS.VPC.Subnet') {
          return subnetAry.push(comp);
        }
      });
      azAry = [];
      _.each(subnetRefAry, function(subnetRef) {
        var subnetAZ, subnetComp;
        subnetUID = subnetRef.split('.')[0].slice(1);
        subnetComp = MC.canvas_data.component[subnetUID];
        subnetAZ = subnetComp.resource.AvailabilityZone;
        azAry.push(subnetAZ);
        return null;
      });
      azSubnetNumMap = {};
      _.each(azAry, function(azName) {
        azSubnetNumMap[azName] = 0;
        _.each(subnetAry, function(subnetComp) {
          var subnetAZ;
          subnetAZ = subnetComp.resource.AvailabilityZone;
          if (subnetAZ === azName) {
            azSubnetNumMap[azName]++;
          }
          return null;
        });
        return null;
      });
      currentAZ = MC.canvas_data.component[subnetUID].resource.AvailabilityZone;
      _.each(azSubnetNumMap, function(subnetNum, azName) {
        if (subnetNum === 1 && azName === currentAZ) {
          isCanDelete = false;
        }
        return null;
      });
      return isCanDelete;
    };
    generateCIDRPossibile = function() {
      var currentVPCCIDR, currentVPCUID, generateSubnetAry, maxSubnetNum, newSubnetCIDRSuffix, result, resultSubnetNum, vpcCIDRAry, vpcCIDRIPStr, vpcCIDRIPStrAry, vpcCIDRSuffix;
      currentVPCUID = MC.aws.vpc.getVPCUID();
      currentVPCCIDR = MC.canvas_data.component[currentVPCUID].resource.CidrBlock;
      vpcCIDRAry = currentVPCCIDR.split('/');
      vpcCIDRIPStr = vpcCIDRAry[0];
      vpcCIDRIPStrAry = vpcCIDRIPStr.split('.');
      vpcCIDRSuffix = Number(vpcCIDRAry[1]);
      if (vpcCIDRSuffix !== 16) {
        return null;
      }
      maxSubnetNum = -1;
      _.each(MC.canvas_data.component, function(comp) {
        var currentSubnetNum, subnetCIDR, subnetCIDRAry, subnetCIDRIPAry, subnetCIDRIPStr, subnetCIDRSuffix;
        if (comp.type === 'AWS.VPC.Subnet') {
          subnetCIDR = comp.resource.CidrBlock;
          subnetCIDRAry = subnetCIDR.split('/');
          subnetCIDRIPStr = subnetCIDRAry[0];
          subnetCIDRSuffix = Number(subnetCIDRAry[1]);
          subnetCIDRIPAry = subnetCIDRIPStr.split('.');
          if (vpcCIDRSuffix === 16) {
            currentSubnetNum = Number(subnetCIDRIPAry[2]);
          }
          if (vpcCIDRSuffix === 24) {
            currentSubnetNum = Number(subnetCIDRIPAry[3]);
          }
          if (maxSubnetNum < currentSubnetNum) {
            return maxSubnetNum = currentSubnetNum;
          }
        }
      });
      resultSubnetNum = maxSubnetNum + 1;
      if (resultSubnetNum > 255) {
        return null;
      }
      generateSubnetAry = vpcCIDRIPStrAry;
      newSubnetCIDRSuffix = '';
      if (vpcCIDRSuffix === 16) {
        generateSubnetAry[2] = String(resultSubnetNum);
        newSubnetCIDRSuffix = '24';
      }
      result = generateSubnetAry.join('.') + '/' + newSubnetCIDRSuffix;
      return result;
    };
    return {
      genCIDRPrefixSuffix: genCIDRPrefixSuffix,
      isSubnetConflict: isSubnetConflict,
      isInVPCCIDR: isInVPCCIDR,
      autoAssignAllCIDR: autoAssignAllCIDR,
      genCIDRDivAry: genCIDRDivAry,
      getVPC: getVPC,
      updateAllENIIPList: updateAllENIIPList,
      isSubnetConflictInVPC: isSubnetConflictInVPC,
      autoAssignSimpleCIDR: autoAssignSimpleCIDR,
      canDeleteSubnetToELBConnection: canDeleteSubnetToELBConnection,
      generateCIDRPossibile: generateCIDRPossibile
    };
  });

}).call(this);
