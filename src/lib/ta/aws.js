(function() {
  define(['MC', 'constant', 'underscore', 'jquery'], function(MC, constant, _, $) {
    var cacheResource, checkAppName, checkDefaultVPC, checkIsRepeatName, checkResource, checkStackName, disabledAllOperabilityArea, getCost, getDuplicateName, getNewName, getRegionName, isExistResourceInApp, regionNameMap;
    getNewName = function(compType) {
      var idx, name_list, name_prefix, new_name;
      new_name = "";
      name_prefix = "";
      name_list = [];
      switch (compType) {
        case constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance:
          name_prefix = "host";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair:
          name_prefix = "kp";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup:
          name_prefix = "custom-sg-";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP:
          name_prefix = "eip";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume:
          name_prefix = "vol";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_ELB:
          name_prefix = "load-balancer-";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC:
          name_prefix = "vpc";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet:
          name_prefix = "subnet";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable:
          name_prefix = "RT-";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway:
          name_prefix = "customer-gateway-";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface:
          name_prefix = "eni";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions:
          name_prefix = "dhcp";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection:
          name_prefix = "vpn";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl:
          name_prefix = "acl";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate:
          name_prefix = "iam";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway:
          name_prefix = "Internet-gateway";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway:
          name_prefix = "VPN-gateway";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group:
          name_prefix = "asg";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration:
          name_prefix = "launch-config-";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration:
          name_prefix = "asl-nc";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy:
          name_prefix = "asl-sp-";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScheduledActions:
          name_prefix = "asl-sa-";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch:
          name_prefix = "clw-";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription:
          name_prefix = "sns-sub";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic:
          name_prefix = "sns-topic";
      }
      _.each(MC.canvas_data.component, function(compObj) {
        if (compObj.type === compType) {
          name_list.push(compObj.name);
        }
        return null;
      });
      idx = 1;
      while (idx <= name_list.length) {
        if ($.inArray(name_prefix + idx, name_list) === -1) {
          break;
        }
        idx++;
      }
      return name_prefix + idx;
    };
    cacheResource = function(resources, region) {
      var error;
      if (!resources || !region || !MC.data.resource_list) {
        console.log('cacheResource failed');
        return null;
      }
      try {
        if (resources.DescribeVpcs) {
          _.map(resources.DescribeVpcs, function(res, i) {
            MC.data.resource_list[region][res.vpcId] = res;
            return null;
          });
        }
        if (resources.DescribeInstances) {
          _.map(resources.DescribeInstances, function(res, i) {
            MC.data.resource_list[region][res.instanceId] = res;
            return null;
          });
        }
        if (resources.DescribeVolumes) {
          _.map(resources.DescribeVolumes, function(res, i) {
            MC.data.resource_list[region][res.volumeId] = res;
            return null;
          });
        }
        if (resources.DescribeAddresses) {
          _.map(resources.DescribeAddresses, function(res, i) {
            MC.data.resource_list[region][res.publicIp] = res;
            return null;
          });
        }
        if (resources.DescribeLoadBalancers) {
          _.map(resources.DescribeLoadBalancers, function(res, i) {
            MC.data.resource_list[region][res.LoadBalancerName] = res;
            return null;
          });
        }
        if (resources.DescribeVpnConnections) {
          _.map(resources.DescribeVpnConnections, function(res, i) {
            MC.data.resource_list[region][res.vpnConnectionId] = res;
            return null;
          });
        }
        if (resources.DescribeKeyPairs) {
          _.map(resources.DescribeKeyPairs, function(res, i) {
            MC.data.resource_list[region][res.keyFingerprint] = res;
            return null;
          });
        }
        if (resources.DescribeSecurityGroups) {
          _.map(resources.DescribeSecurityGroups, function(res, i) {
            MC.data.resource_list[region][res.groupId] = res;
            return null;
          });
        }
        if (resources.DescribeDhcpOptions) {
          _.map(resources.DescribeDhcpOptions, function(res, i) {
            MC.data.resource_list[region][res.dhcpOptionsId] = res;
            return null;
          });
        }
        if (resources.DescribeSubnets) {
          _.map(resources.DescribeSubnets, function(res, i) {
            MC.data.resource_list[region][res.subnetId] = res;
            return null;
          });
        }
        if (resources.DescribeRouteTables) {
          _.map(resources.DescribeRouteTables, function(res, i) {
            MC.data.resource_list[region][res.routeTableId] = res;
            return null;
          });
        }
        if (resources.DescribeNetworkAcls) {
          _.map(resources.DescribeNetworkAcls, function(res, i) {
            MC.data.resource_list[region][res.networkAclId] = res;
            return null;
          });
        }
        if (resources.DescribeNetworkInterfaces) {
          _.map(resources.DescribeNetworkInterfaces, function(res, i) {
            MC.data.resource_list[region][res.networkInterfaceId] = res;
            return null;
          });
        }
        if (resources.DescribeInternetGateways) {
          _.map(resources.DescribeInternetGateways, function(res, i) {
            MC.data.resource_list[region][res.internetGatewayId] = res;
            return null;
          });
        }
        if (resources.DescribeVpnGateways) {
          _.map(resources.DescribeVpnGateways, function(res, i) {
            MC.data.resource_list[region][res.vpnGatewayId] = res;
            return null;
          });
        }
        if (resources.DescribeCustomerGateways) {
          _.map(resources.DescribeCustomerGateways, function(res, i) {
            MC.data.resource_list[region][res.customerGatewayId] = res;
            return null;
          });
        }
        if (resources.DescribeImages) {
          _.map(resources.DescribeImages, function(res, i) {
            if (!res.osType) {
              res = $.extend(true, {}, res);
              res.osType = MC.aws.ami.getOSType(res);
            }
            MC.data.dict_ami[res.imageId] = res;
            MC.data.resource_list[region][res.imageId] = res;
            return null;
          });
        }
        if (resources.DescribeAutoScalingGroups) {
          _.map(resources.DescribeAutoScalingGroups, function(res, i) {
            MC.data.resource_list[region][res.AutoScalingGroupARN] = res;
            return null;
          });
        }
        if (resources.DescribeLaunchConfigurations) {
          _.map(resources.DescribeLaunchConfigurations, function(res, i) {
            MC.data.resource_list[region][res.LaunchConfigurationARN] = res;
            return null;
          });
        }
        if (resources.DescribeNotificationConfigurations) {
          if (!MC.data.resource_list[region].NotificationConfigurations) {
            MC.data.resource_list[region].NotificationConfigurations = [];
          }
          _.map(resources.DescribeNotificationConfigurations, function(res, i) {
            MC.data.resource_list[region].NotificationConfigurations.push(res);
            return null;
          });
        }
        if (resources.DescribePolicies) {
          _.map(resources.DescribePolicies, function(res, i) {
            MC.data.resource_list[region][res.PolicyARN] = res;
            return null;
          });
        }
        if (resources.DescribeScheduledActions) {
          _.map(resources.DescribeScheduledActions, function(res, i) {
            MC.data.resource_list[region][res.ScheduledActionARN] = res;
            return null;
          });
        }
        if (resources.DescribeAlarms) {
          _.map(resources.DescribeAlarms, function(res, i) {
            MC.data.resource_list[region][res.AlarmArn] = res;
            return null;
          });
        }
        if (resources.ListSubscriptions) {
          if (!MC.data.resource_list[region].Subscriptions) {
            MC.data.resource_list[region].Subscriptions = [];
          }
          _.map(resources.ListSubscriptions, function(res, i) {
            MC.data.resource_list[region].Subscriptions.push(res);
            return null;
          });
        }
        if (resources.ListTopics) {
          _.map(resources.ListTopics, function(res, i) {
            MC.data.resource_list[region][res.TopicArn] = res;
            return null;
          });
        }
        if (resources.DescribeAutoScalingInstances) {
          _.map(resources.DescribeAutoScalingInstances, function(res, i) {
            MC.data.resource_list[region][res.AutoScalingGroupName + ':' + res.InstanceId] = res;
            return null;
          });
        }
        if (resources.DescribeScalingActivities) {
          _.map(resources.DescribeScalingActivities, function(res, i) {
            MC.data.resource_list[region][res.ActivityId] = res;
            return null;
          });
        }
        if (resources.DescribeInstanceHealth) {
          if (!MC.data.resource_list[region].instance_health) {
            MC.data.resource_list[region].instance_health = {};
          }
          _.map(resources.DescribeInstanceHealth, function(res, i) {
            MC.data.resource_list[region].instance_health[res.InstanceId] = res;
            return null;
          });
        }
      } catch (_error) {
        error = _error;
        console.info(error);
      }
      return null;
    };
    checkIsRepeatName = function(compUID, newName) {
      var originCompObj, originCompType, originCompUID;
      originCompObj = MC.canvas_data.component[compUID];
      originCompUID = originCompObj.uid;
      originCompType = originCompObj.type;
      return !_.some(MC.canvas_data.component, function(compObj) {
        var compName, compType;
        compUID = compObj.uid;
        compType = compObj.type;
        compName = compObj.name;
        if (originCompType === compType && originCompUID !== compUID && newName === compName) {
          return true;
        }
      });
    };
    checkStackName = function(stackId, newName) {
      var stackArray;
      stackArray = _.flatten(_.values(MC.data.stack_list));
      return !_.some(stackArray, function(stack) {
        return stack.id !== stackId && stack.name === newName;
      });
    };
    checkAppName = function(name) {
      var appArray;
      appArray = _.flatten(_.values(MC.data.app_list));
      return !_.contains(appArray, name);
    };
    disabledAllOperabilityArea = function(enabled) {
      if (enabled) {
        $('#resource-panel').append('<div class="disabled-event-layout"></div>');
        $('#canvas').append('<div class="disabled-event-layout"></div>');
        return $('#tabbar-wrapper').append('<div class="disabled-event-layout"></div>');
      } else {
        return $('.disabled-event-layout').remove();
      }
    };
    getDuplicateName = function(stack_name) {
      var copy_name, i, idx, name_list, stacks, _i, _len;
      copy_name = stack_name + "-copy-";
      name_list = [];
      stacks = _.flatten(_.values(MC.data.stack_list));
      for (_i = 0, _len = stacks.length; _i < _len; _i++) {
        i = stacks[_i];
        if (i.name.indexOf(copy_name) === 0) {
          name_list.push(i.name);
        }
      }
      idx = 1;
      while (idx <= name_list.length) {
        if ($.inArray(copy_name + idx, name_list) === -1) {
          break;
        }
        idx++;
      }
      return copy_name + idx;
    };
    getCost = function(data) {
      var cost_list, feeMap, me, region, total_fee;
      me = this;
      cost_list = [];
      total_fee = 0;
      region = data.region;
      feeMap = MC.data.config[region];
      if (!(feeMap && feeMap.ami && feeMap.price)) {
        return {
          'cost_list': cost_list,
          'total_fee': total_fee
        };
      }
      _.map(data.component, function(item) {
        var ami, asg_price, block, cap, com, config, config_uid, elb, fee, i, imageId, k, name, number, os, period, size, size_list, type, uid, unit, v, vol, vol_fee, vol_uid, vols, volume, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
        uid = item.uid;
        name = item.name;
        type = item.type;
        if (item.type === 'AWS.EC2.Instance') {
          size = item.resource.InstanceType;
          imageId = item.resource.ImageId;
          number = item.number ? item.number : 1;
          if ('ami' in feeMap) {
            fee = unit = null;
            if (imageId in feeMap.ami) {
              _ref = feeMap.ami;
              for (k in _ref) {
                v = _ref[k];
                if (v.imageId === imageId) {
                  ami = v;
                }
              }
              if (feeMap.ami[imageId].osType === 'win') {
                os = 'windows';
              } else {
                os = 'linux-other';
              }
              size_list = size.split('.');
              fee = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].fee;
              unit = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].unit;
            } else if (imageId in MC.data.dict_ami) {
              com = MC.data.dict_ami[imageId];
              if (com.osType === 'win') {
                os = 'windows';
              } else {
                os = 'linux-other';
              }
              size_list = size.split('.');
              fee = feeMap.price['instance'][os][size_list[0]][size_list[1]].fee;
              unit = feeMap.price['instance'][os][size_list[0]][size_list[1]].unit;
            }
            if (fee && unit) {
              cost_list.push({
                'resource': name,
                'size': size,
                'fee': fee + (unit === 'hour' ? '/hr' : '/mo')
              });
              total_fee += fee * 24 * 30 * number;
              if (item.resource.Monitoring === 'enabled') {
                fee = 3.50;
                cost_list.push({
                  'resource': name,
                  'type': 'Detailed Monitoring',
                  'fee': fee + '/mo'
                });
                total_fee += fee;
              }
            }
          }
          vols = item.resource.BlockDeviceMapping;
          if (vols && 'price' in feeMap && 'ebs' in feeMap.price) {
            for (_i = 0, _len = vols.length; _i < _len; _i++) {
              vol_uid = vols[_i];
              volume = data.component[vol_uid.split('#')[1]];
              if (volume.resource.VolumeType === 'standard') {
                _ref1 = feeMap.price.ebs.ebsVols;
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  i = _ref1[_j];
                  if (i.unit === 'perGBmoProvStorage') {
                    vol_fee = i;
                  }
                }
              } else {
                _ref2 = feeMap.price.ebs.ebsPIOPSVols;
                for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
                  i = _ref2[_k];
                  if (i.unit === 'perGBmoProvStorage') {
                    vol_fee = i;
                  }
                }
              }
              cost_list.push({
                'resource': name + ' - ' + volume.name,
                'size': volume.resource.Size + 'G',
                'fee': vol_fee.fee + '/GB/mo'
              });
              total_fee += parseFloat(vol_fee.fee * volume.resource.Size * number);
            }
          }
        } else if (item.type === 'AWS.ELB') {
          if ('price' in feeMap && 'elb' in feeMap.price) {
            _ref3 = feeMap.price.elb;
            for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
              i = _ref3[_l];
              if (i.unit === 'perELBHour') {
                elb = i;
              }
            }
            cost_list.push({
              'type': type,
              'resource': name,
              'fee': elb.fee + '/hr'
            });
            total_fee += elb.fee * 24 * 30;
          }
        } else if (item.type === 'AWS.AutoScaling.Group') {
          cap = item.resource.DesiredCapacity ? item.resource.DesiredCapacity : item.resource.MinSize;
          config_uid = MC.extractID(item.resource.LaunchConfigurationName);
          config = MC.canvas_data.component[config_uid];
          if (config) {
            asg_price = 0;
            imageId = config.resource.ImageId;
            size = config.resource.InstanceType;
            _ref4 = feeMap.ami;
            for (k in _ref4) {
              v = _ref4[k];
              if (v.imageId === imageId) {
                ami = v;
              }
            }
            if ('ami' in feeMap && imageId in feeMap.ami) {
              if (feeMap.ami[imageId].osType === 'win') {
                os = 'windows';
              } else {
                os = 'linux-other';
              }
              size_list = size.split('.');
              fee = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].fee;
              unit = feeMap.ami[imageId].price[os][size_list[0]][size_list[1]].unit;
              if (unit === 'hour') {
                asg_price += fee * 24 * 30;
              } else {
                asg_price += fee;
              }
            }
            if (config.resource.BlockDeviceMapping) {
              _ref5 = config.resource.BlockDeviceMapping;
              for (_m = 0, _len4 = _ref5.length; _m < _len4; _m++) {
                block = _ref5[_m];
                _ref6 = feeMap.price.ebs.ebsVols;
                for (_n = 0, _len5 = _ref6.length; _n < _len5; _n++) {
                  i = _ref6[_n];
                  if (i.unit === 'perGBmoProvStorage') {
                    vol = i;
                  }
                }
                asg_price += block.Ebs.VolumeSize * vol.fee;
              }
            }
            if (asg_price > 0) {
              cost_list.push({
                'resource': name,
                'size': cap,
                'fee': asg_price.toFixed(3) + '/mo'
              });
              total_fee += asg_price * cap;
            }
            if (config.resource.InstanceMonitoring === 'enabled') {
              fee = 3.50;
              cost_list.push({
                'resource': name,
                'type': 'Detailed Monitoring',
                'fee': fee + '/mo'
              });
              total_fee += fee;
            }
          }
        } else if (item.type === 'AWS.CloudWatch.CloudWatch') {
          period = parseInt(item.resource.Period, 10);
          if (period && period <= 300) {
            fee = 0.10;
            cost_list.push({
              'resource': name,
              'size': '',
              'fee': fee + '/mo'
            });
            total_fee += fee;
          }
        }
        return null;
      });
      cost_list.sort(function(a, b) {
        if (a.type <= b.type) {
          return 1;
        } else {
          return -1;
        }
      });
      return {
        'cost_list': cost_list,
        'total_fee': total_fee.toFixed(2)
      };
    };
    checkDefaultVPC = function() {
      var accountData, currentRegion;
      currentRegion = MC.canvas_data.region;
      accountData = MC.data.account_attribute[currentRegion];
      if (accountData.support_platform === 'VPC' && MC.canvas_data.platform === 'default-vpc') {
        return accountData.default_vpc;
      } else {
        return false;
      }
    };
    checkResource = function(uid) {
      var c_uid, comp, components, data, r, res, res_type;
      if (uid) {
        components = {
          uid: MC.canvas_data.component[uid]
        };
      } else {
        components = MC.canva_data.component;
      }
      res = {};
      res_type = constant.AWS_RESOURCE_TYPE;
      data = MC.data.resource_list[MC.canvas_data.region];
      for (c_uid in components) {
        comp = components[c_uid];
        r = true;
        switch (comp.type) {
          case res_type.AWS_VPC_NetworkAcl:
            r = data[comp.resource.NetworkAclId];
            break;
          case res_type.AWS_AutoScaling_Group:
            r = data[comp.resource.AutoScalingGroupARN];
            break;
          case res_type.AWS_VPC_CustomerGateway:
            r = data[comp.resource.CustomerGatewayId];
            break;
          case res_type.AWS_ELB:
            r = data[comp.resource.LoadBalancerName];
            break;
          case res_type.AWS_VPC_NetworkInterface:
            r = data[comp.resource.NetworkInterfaceId];
            break;
          case res_type.AWS_EC2_Instance:
            r = data[comp.resource.InstanceId];
            break;
          case res_type.AWS_AutoScaling_LaunchConfiguration:
            r = data[comp.resource.LaunchConfigurationARN];
            break;
          case res_type.AWS_VPC_RouteTable:
            r = data[comp.resource.RouteTableId];
            break;
          case res_type.AWS_VPC_Subnet:
            r = data[comp.resource.SubnetId];
            break;
          case res_type.AWS_EBS_Volume:
            r = data[comp.resource.VolumeId];
            break;
          case res_type.AWS_VPC_VPC:
            r = data[comp.resource.VpcId];
        }
        res[c_uid] = r ? true : false;
      }
      if (uid) {
        return res[uid];
      } else {
        return res;
      }
    };
    regionNameMap = {
      'us-west-1': ['US West', 'N. California'],
      'us-west-2': ['US West', 'Oregon'],
      'us-east-1': ['US East', 'Virginia'],
      'eu-west-1': ['EU West', 'Ireland'],
      'ap-southeast-1': ['Asia Pacific', 'Singapore'],
      'ap-southeast-2': ['Asia Pacific', 'Sydney'],
      'ap-northeast-1': ['Asia Pacific', 'Tokyo'],
      'sa-east-1': ['South America', 'Sao Paulo']
    };
    getRegionName = function(region, option) {
      if (region in regionNameMap) {
        if (option === 'fullname') {
          return "" + regionNameMap[region][0] + " - " + regionNameMap[region][1];
        }
        return regionNameMap[region][1];
      } else {
        return null;
      }
    };
    isExistResourceInApp = function(compUID) {
      var compObj, compRes, compType, region, resourceId;
      compObj = MC.canvas_data.component[compUID];
      if (!compObj) {
        return true;
      }
      compType = compObj.type;
      compRes = compObj.resource;
      resourceId = null;
      switch (compType) {
        case constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance:
          resourceId = compRes.InstanceId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair:
          resourceId = compRes.KeyFingerprint;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup:
          resourceId = compRes.GroupId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_EC2_EIP:
          resourceId = compRes.PublicIp;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume:
          resourceId = compRes.VolumeId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_ELB:
          resourceId = compRes.LoadBalancerName;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC:
          resourceId = compRes.VpcId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet:
          resourceId = compRes.SubnetId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable:
          resourceId = compRes.RouteTableId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway:
          resourceId = compRes.CustomerGatewayId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface:
          resourceId = compRes.NetworkInterfaceId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_DhcpOptions:
          resourceId = compRes.DhcpOptionsId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection:
          resourceId = compRes.VpnConnectionId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl:
          resourceId = compRes.NetworkAclId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate:
          resourceId = compRes.ServerCertificateMetadata.ServerCertificateId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway:
          resourceId = compRes.InternetGatewayId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway:
          resourceId = compRes.VpnGatewayId;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group:
          resourceId = compRes.AutoScalingGroupARN;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration:
          resourceId = compRes.LaunchConfigurationARN;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration:
          resourceId = "asl-nc";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScalingPolicy:
          resourceId = compRes.PolicyARN;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_ScheduledActions:
          resourceId = compRes.ScheduledActionARN;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_CloudWatch_CloudWatch:
          resourceId = compRes.AlarmArn;
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_SNS_Subscription:
          resourceId = "sns-sub";
          break;
        case constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic:
          resourceId = compRes.TopicArn;
      }
      region = MC.canvas_data.region;
      if (!resourceId || (resourceId && MC.data.resource_list[region][resourceId])) {
        return true;
      } else {
        return false;
      }
    };
    return {
      getNewName: getNewName,
      cacheResource: cacheResource,
      checkIsRepeatName: checkIsRepeatName,
      checkStackName: checkStackName,
      checkAppName: checkAppName,
      getDuplicateName: getDuplicateName,
      disabledAllOperabilityArea: disabledAllOperabilityArea,
      getCost: getCost,
      checkDefaultVPC: checkDefaultVPC,
      checkResource: checkResource,
      getRegionName: getRegionName,
      isExistResourceInApp: isExistResourceInApp
    };
  });

}).call(this);
