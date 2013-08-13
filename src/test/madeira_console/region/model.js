(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['MC', 'backbone', 'jquery', 'underscore', 'event', 'app_model', 'stack_model', 'aws_model', 'ami_model', 'elb_model', 'dhcp_model', 'vpngateway_model', 'customergateway_model', 'vpc_model', 'constant'], function(MC, Backbone, $, _, ide_event, app_model, stack_model, aws_model, ami_model, elb_model, dhcp_model, vpngateway_model, customergateway_model, vpc_model, constant) {
    var RegionModel, current_region, model, owner, popup_key_set, resource_source, status_list, unmanaged_list, update_timestamp, vpc_attrs_value, ws;
    current_region = null;
    resource_source = null;
    vpc_attrs_value = null;
    unmanaged_list = null;
    status_list = null;
    owner = null;
    update_timestamp = 0;
    popup_key_set = {
      "unmanaged_bubble": {
        "DescribeVolumes": {
          "status": ["status"],
          "title": "volumeId",
          "sub_info": [
            {
              "key": ["createTime"],
              "show_key": "Create Time"
            }, {
              "key": ["availabilityZone"],
              "show_key": "Availability Zone"
            }, {
              "key": ["attachmentSet", "item", "status"],
              "show_key": "Attachment Status"
            }
          ]
        },
        "DescribeCustomerGateways": {
          "title": "customerGatewayId",
          "status": "state",
          "sub_info": [
            {
              "key": ["customerGatewayId"],
              "show_key": "CustomerGatewayId"
            }, {
              "key": ["type"],
              "show_key": "Type"
            }, {
              "key": ["ipAddress"],
              "show_key": "IpAddress"
            }, {
              "key": ["bgpAsn"],
              "show_key": "BgpAsn"
            }
          ]
        },
        "DescribeVpnGateways": {
          "title": "vpnGatewayId",
          "status": "state",
          "sub_info": [
            {
              "key": ["vpnGatewayId"],
              "show_key": "VPNGatewayId"
            }, {
              "key": ["type"],
              "show_key": "Type"
            }
          ]
        },
        "DescribeInstances": {
          "status": ["instanceState", "name"],
          "title": "instanceId",
          "sub_info": [
            {
              "key": ["launchTime"],
              "show_key": "Launch Time"
            }, {
              "key": ["placement", "availabilityZone"],
              "show_key": "Availability Zone"
            }
          ]
        },
        "DescribeVpnConnections": {
          "status": ["state"],
          "title": "vpnConnectionId",
          "sub_info": [
            {
              "key": ["vpnConnectionId"],
              "show_key": "VPC"
            }, {
              "key": ["type"],
              "show_key": "Type"
            }, {
              "key": ["routes", "item", "source"],
              "show_key": "Routing"
            }
          ]
        },
        "DescribeVpcs": {
          "status": ["state"],
          "title": "vpcId",
          "sub_info": [
            {
              "key": ["cidrBlock"],
              "show_key": "CIDR"
            }, {
              "key": ["isDefault"],
              "show_key": "Default VPC:"
            }, {
              "key": ["instanceTenancy"],
              "show_key": "Tenacy"
            }
          ]
        }
      },
      "detail": {
        "DescribeVolumes": {
          "title": "volumeId",
          "sub_info": [
            {
              "key": ["volumeId"],
              "show_key": "Volume ID"
            }, {
              "key": ["attachmentSet", "item", 0, "device"],
              "show_key": "Device Name"
            }, {
              "key": ["snapshotId"],
              "show_key": "Snapshot ID"
            }, {
              "key": ["size"],
              "show_key": "Volume Size(GiB)"
            }, {
              "key": ["createTime"],
              "show_key": "Create Time"
            }, {
              "key": ["attachmentSet"],
              "show_key": "AttachmentSet"
            }, {
              "key": ["status"],
              "show_key": "status"
            }, {
              "key": ["attachmentSet", "item", "status"],
              "show_key": "AttachmentSet"
            }, {
              "key": ["availabilityZone"],
              "show_key": "Availability Zone"
            }, {
              "key": ["volumeType"],
              "show_key": "Volume Type"
            }, {
              "key": ["Iops"],
              "show_key": "Iops"
            }
          ]
        },
        "DescribeInstances": {
          "title": "instanceId",
          "sub_info": [
            {
              "key": ["instanceState", "name"],
              "show_key": "Status"
            }, {
              "key": ["keyName"],
              "show_key": "Key Pair Name"
            }, {
              "key": ["monitoring", "state"],
              "show_key": "Monitoring"
            }, {
              "key": ["ipAddress"],
              "show_key": "Primary Public IP"
            }, {
              "key": ["dnsName"],
              "show_key": "Public DNS"
            }, {
              "key": ["privateIpAddress"],
              "show_key": "Primary Private IP"
            }, {
              "key": ["privateDnsName"],
              "show_key": "Private DNS"
            }, {
              "key": ["launchTime"],
              "show_key": "Launch Time"
            }, {
              "key": ["placement", "availabilityZone"],
              "show_key": "Zone"
            }, {
              "key": ["amiLaunchIndex"],
              "show_key": "AMI Launch Index"
            }, {
              "key": ["instanceType"],
              "show_key": "Instance Type"
            }, {
              "key": ["ebsOptimized"],
              "show_key": "EBS Optimized"
            }, {
              "key": ["rootDeviceType"],
              "show_key": "Root Device Type"
            }, {
              "key": ["placement", "tenancy"],
              "show_key": "Tenancy"
            }, {
              "key": ["blockDeviceMapping", "item"],
              "show_key": "Block Devices"
            }, {
              "key": ['networkInterfaceSet', 'item'],
              "show_key": "NetworkInterface"
            }
          ]
        },
        "DescribeVpnConnections": {
          "title": "vpnConnectionId",
          "sub_info": [
            {
              "key": ["state"],
              "show_key": "State"
            }, {
              "key": ["vpnGatewayId"],
              "show_key": "Virtual Private Gateway"
            }, {
              "key": ["customerGatewayId"],
              "show_key": "Customer Gateway"
            }, {
              "key": ["type"],
              "show_key": "Type"
            }, {
              "key": ["routes", "item", 0],
              "show_key": "Routing"
            }
          ],
          "btns": [
            {
              "type": "download_configuration",
              "name": "Download Configuration"
            }
          ],
          "detail_table": [
            {
              "key": ["vgwTelemetry", "item"],
              "show_key": "VPN Tunnel",
              "count_name": "tunnel"
            }, {
              "key": ["outsideIpAddress"],
              "show_key": "IP Address"
            }, {
              "key": ["status"],
              "show_key": "Status"
            }, {
              "key": ["lastStatusChange"],
              "show_key": "Last Changed"
            }, {
              "key": ["statusMessage"],
              "show_key": "Detail"
            }
          ]
        },
        "DescribeVpcs": {
          "title": "vpcId",
          "sub_info": [
            {
              "key": ["state"],
              "show_key": "State"
            }, {
              "key": ["cidrBlock"],
              "show_key": "CIDR"
            }, {
              "key": ["instanceTenancy"],
              "show_key": "Tenancy"
            }
          ]
        },
        "DescribeLoadBalancers": {
          "title": "LoadBalancerName",
          "sub_info": [
            {
              "key": ["state"],
              "show_key": "State"
            }, {
              "key": ["AvailabilityZones", "member"],
              "show_key": "AvailabilityZones"
            }, {
              "key": ["CreatedTime"],
              "show_key": "CreatedTime"
            }, {
              "key": ["DNSName"],
              "show_key": "DNSName"
            }, {
              "key": ["HealthCheck"],
              "show_key": "HealthCheck"
            }, {
              "key": ["Instances", 'member'],
              "show_key": "Instances"
            }, {
              "key": ["ListenerDescriptions", "member"],
              "show_key": "ListenerDescriptions"
            }, {
              "key": ["SecurityGroups", "member"],
              "show_key": "SecurityGroups"
            }, {
              "key": ["Subnets", "member"],
              "show_key": "Subnets"
            }
          ]
        },
        "DescribeAddresses": {
          "title": "publicIp",
          "sub_info": [
            {
              "key": ["domain"],
              "show_key": "Domain"
            }, {
              "key": ["instanceId"],
              "show_key": "InstanceId"
            }, {
              "key": ["publicIp"],
              "show_key": "PublicIp"
            }, {
              "key": ["associationId"],
              "show_key": "AssociationId"
            }, {
              "key": ["allocationId"],
              "show_key": "AllocationId"
            }, {
              "key": ["networkInterfaceId"],
              "show_key": "NetworkInterfaceId"
            }, {
              "key": ["privateIpAddress"],
              "show_key": "PrivateIpAddress"
            }, {
              "key": ["SecurityGroups"],
              "show_key": "SecurityGroups"
            }, {
              "key": ["Subnets"],
              "show_key": "Subnets"
            }
          ]
        },
        "DescribeAutoScalingGroups": {
          "title": "AutoScalingGroupName",
          "sub_info": [
            {
              "key": ["AutoScalingGroupName"],
              "show_key": "AutoScalingGroupName"
            }, {
              "key": ["AutoScalingGroupARN"],
              "show_key": "AutoScalingGroupARN"
            }, {
              "key": ["AvailabilityZones"],
              "show_key": "AvailabilityZones"
            }, {
              "key": ["CreatedTime"],
              "show_key": "CreatedTime"
            }, {
              "key": ["DefaultCooldown"],
              "show_key": "DefaultCooldown"
            }, {
              "key": ["DesiredCapacity"],
              "show_key": "DesiredCapacity"
            }, {
              "key": ["EnabledMetrics"],
              "show_key": "EnabledMetrics"
            }, {
              "key": ["HealthCheckGracePeriod"],
              "show_key": "HealthCheckGracePeriod"
            }, {
              "key": ["HealthCheckType"],
              "show_key": "HealthCheckType"
            }, {
              "key": ["Instances"],
              "show_key": "Instances"
            }, {
              "key": ["LaunchConfigurationName"],
              "show_key": "LaunchConfigurationName"
            }, {
              "key": ["LoadBalancerNames"],
              "show_key": "LoadBalancerNames"
            }, {
              "key": ["MaxSize"],
              "show_key": "MaxSize"
            }, {
              "key": ["MinSize"],
              "show_key": "MinSize"
            }, {
              "key": ["Status"],
              "show_key": "Status"
            }, {
              "key": ["TerminationPolicies"],
              "show_key": "TerminationPolicies"
            }, {
              "key": ["VPCZoneIdentifier"],
              "show_key": "VPCZoneIdentifier"
            }
          ]
        },
        "DescribeAlarms": {
          "title": "AlarmName",
          "sub_info": [
            {
              "key": ["ActionsEnabled"],
              "show_key": "ActionsEnabled"
            }, {
              "key": ["AlarmActions"],
              "show_key": "AlarmActions"
            }, {
              "key": ["AlarmArn"],
              "show_key": "AlarmArn"
            }, {
              "key": ["AlarmDescription"],
              "show_key": "AlarmDescription"
            }, {
              "key": ["AlarmName"],
              "show_key": "AlarmName"
            }, {
              "key": ["ComparisonOperator"],
              "show_key": "ComparisonOperator"
            }, {
              "key": ["Dimensions"],
              "show_key": "Dimensions"
            }, {
              "key": ["EvaluationPeriods"],
              "show_key": "EvaluationPeriods"
            }, {
              "key": ["InsufficientDataActions"],
              "show_key": "InsufficientDataActions"
            }, {
              "key": ["MetricName"],
              "show_key": "MetricName"
            }, {
              "key": ["Namespace"],
              "show_key": "Namespace"
            }, {
              "key": ["OKActions"],
              "show_key": "OKActions"
            }, {
              "key": ["Period"],
              "show_key": "Period"
            }, {
              "key": ["Statistic"],
              "show_key": "Statistic"
            }, {
              "key": ["StateValue"],
              "show_key": "StateValue"
            }, {
              "key": ["Threshold"],
              "show_key": "Threshold"
            }, {
              "key": ["Unit"],
              "show_key": "Unit"
            }
          ]
        }
      }
    };
    ws = MC.data.websocket;
    RegionModel = Backbone.Model.extend({
      defaults: {
        'cur_app_list': null,
        'cur_stack_list': null,
        'region_resource_list': null,
        'region_resource': null,
        'resourse_list': null,
        'vpc_attrs': null,
        'unmanaged_list': null,
        'status_list': null
      },
      initialize: function() {
        var me;
        me = this;
        aws_model.on('AWS_RESOURCE_RETURN', function(result) {
          _.map(result.resolved_data, function(value, key) {
            console.log('AWS_RESOURCE_RETURN:' + key);
            me.setResource(value, key);
            return null;
          });
          me.updateUnmanagedList();
          ide_event.trigger('AWS_RESOURCE_CHANGE');
          return null;
        });
        return null;
      },
      resetData: function() {
        var lists, me, resource, time_stamp;
        me = this;
        time_stamp = new Date().getTime() / 1000;
        unmanaged_list = {
          loading: true,
          "time_stamp": time_stamp,
          "items": []
        };
        me.set('unmanaged_list', unmanaged_list);
        me.set('vpc_attrs', {});
        me.set('status_list', {});
        lists = {
          loading: true,
          ELB: 0,
          EIP: 0,
          Instance: 0,
          VPC: 0,
          VPN: 0,
          Volume: 0
        };
        me.set('region_resource_list', lists);
        resource = {
          DescribeLoadBalancers: null,
          DescribeInstances: null,
          DescribeVpcs: null,
          DescribeAddresses: null,
          DescribeImages: null,
          DescribeVpnGateways: null
        };
        return me.set('region_resource', resource);
      },
      getItemList: function(flag, region, result) {
        var cur_item_list, item_list, me, regions, _i, _len;
        me = this;
        for (_i = 0, _len = result.length; _i < _len; _i++) {
          regions = result[_i];
          if (constant.REGION_LABEL[region] === regions.region_group) {
            item_list = regions.region_name_group;
          }
        }
        cur_item_list = [];
        _.map(item_list, function(value) {
          var item;
          item = me.parseItem(value, flag);
          if (item) {
            cur_item_list.push(item);
            return null;
          }
        });
        if (cur_item_list) {
          cur_item_list.sort(function(a, b) {
            if (a.create_time <= b.create_time) {
              return 1;
            } else {
              return -1;
            }
          });
          if (flag === 'app') {
            if (_.difference(me.get('cur_app_list'), cur_item_list)) {
              return me.set('cur_app_list', cur_item_list);
            }
          } else if (flag === 'stack') {
            if (_.difference(me.get('cur_stack_list'), cur_item_list)) {
              return me.set('cur_stack_list', cur_item_list);
            }
          }
        }
      },
      parseItem: function(item, flag) {
        var create_time, date, id, id_code, isrunning, name, start_time, status, stop_time, update_time;
        id = item.id;
        name = item.name;
        create_time = item.time_create;
        update_time = item.time_update;
        id_code = MC.base64Encode(id);
        status = "play";
        isrunning = true;
        if (item.state === constant.APP_STATE.APP_STATE_INITIALIZING) {
          return;
        } else if (item.state === constant.APP_STATE.APP_STATE_RUNNING) {
          status = "play";
        } else if (item.state === constant.APP_STATE.APP_STATE_STOPPED) {
          isrunning = false;
          status = "stop";
        } else {
          status = "pending";
        }
        if (flag === 'app') {
          id_code = MC.base64Encode(item.stack_id);
          date = new Date();
          start_time = null;
          stop_time = null;
          if (item.last_start) {
            date.setTime(item.last_start * 1000);
            start_time = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd");
          }
          if (!isrunning && item.last_stop) {
            date.setTime(item.last_stop * 1000);
            stop_time = "GMT " + MC.dateFormat(date, "hh:mm yyyy-MM-dd");
          }
        }
        return {
          'id': id,
          'code': id_code,
          'update_time': update_time,
          'name': name,
          'create_time': create_time,
          'start_time': start_time,
          'stop_time': stop_time,
          'isrunning': isrunning,
          'status': status,
          'cost': "$0/month"
        };
      },
      runApp: function(region, app_id) {
        var app_name, i, me, _i, _len, _ref;
        me = this;
        current_region = region;
        _ref = me.get('cur_app_list');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (i.id === app_id) {
            app_name = i.name;
          }
        }
        app_model.start({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), region, app_id, app_name);
        return app_model.once('APP_START_RETURN', function(result) {
          var handle, query, req_id;
          console.log('APP_START_RETURN');
          console.log(result);
          if (!result.is_error) {
            if (ws) {
              req_id = result.resolved_data.id;
              console.log("request id:" + req_id);
              query = ws.collection.request.find({
                id: req_id
              });
              handle = query.observeChanges({
                changed: function(id, req) {
                  if (req.state === "Done") {
                    handle.stop();
                    console.log('stop handle');
                    return ide_event.trigger(ide_event.APP_RUN, app_name, app_id);
                  }
                }
              });
            }
            return null;
          }
        });
      },
      stopApp: function(region, app_id) {
        var app_name, i, me, _i, _len, _ref;
        me = this;
        current_region = region;
        _ref = me.get('cur_app_list');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (i.id === app_id) {
            app_name = i.name;
          }
        }
        app_model.stop({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), region, app_id, app_name);
        return app_model.once('APP_STOP_RETURN', function(result) {
          var handle, query, req_id;
          console.log('APP_STOP_RETURN');
          console.log(result);
          if (!result.is_error) {
            if (ws) {
              req_id = result.resolved_data.id;
              console.log("request id:" + req_id);
              query = ws.collection.request.find({
                id: req_id
              });
              handle = query.observeChanges({
                changed: function(id, req) {
                  if (req.state === "Done") {
                    handle.stop();
                    console.log('stop handle');
                    return ide_event.trigger(ide_event.APP_STOP, app_name, app_id);
                  }
                }
              });
            }
            return null;
          }
        });
      },
      terminateApp: function(region, app_id) {
        var app_name, i, me, _i, _len, _ref;
        me = this;
        current_region = region;
        _ref = me.get('cur_app_list');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          if (i.id === app_id) {
            app_name = i.name;
          }
        }
        app_model.terminate({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), region, app_id, app_name);
        return app_model.once('APP_TERMINATE_RETURN', function(result) {
          var handle, query, req_id;
          console.log('APP_TERMINATE_RETURN');
          console.log(result);
          if (!result.is_error) {
            if (ws) {
              req_id = result.resolved_data.id;
              console.log("request id:" + req_id);
              query = ws.collection.request.find({
                id: req_id
              });
              handle = query.observeChanges({
                changed: function(id, req) {
                  if (req.state === "Done") {
                    handle.stop();
                    console.log('stop handle');
                    return ide_event.trigger(ide_event.APP_TERMINATE, app_name, app_id);
                  }
                }
              });
            }
          }
          return null;
        });
      },
      duplicateStack: function(region, stack_id, new_name) {
        var me, s, stack_name, _i, _len, _ref;
        console.log('duplicateStack');
        me = this;
        current_region = region;
        _ref = me.get('cur_stack_list');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          if (s.id === stack_id) {
            stack_name = s.name;
          }
        }
        stack_model.save_as({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), region, stack_id, new_name, stack_name);
        return stack_model.once('STACK_SAVE__AS_RETURN', function(result) {
          console.log('STACK_SAVE__AS_RETURN');
          console.log(result);
          if (!result.is_error) {
            return ide_event.trigger(ide_event.UPDATE_STACK_LIST);
          }
        });
      },
      deleteStack: function(region, stack_id) {
        var me, s, stack_name, _i, _len, _ref;
        me = this;
        current_region = region;
        _ref = me.get('cur_stack_list');
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          s = _ref[_i];
          if (s.id === stack_id) {
            stack_name = s.name;
          }
        }
        stack_model.remove({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), region, stack_id, stack_name);
        return stack_model.once('STACK_REMOVE_RETURN', function(result) {
          console.log('STACK_REMOVE_RETURN');
          console.log(result);
          if (!result.is_error) {
            return ide_event.trigger(ide_event.STACK_DELETE, stack_name, stack_id);
          }
        });
      },
      _genDhcp: function(dhcp) {
        var me, sub_info;
        me = this;
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions = {};
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions.title = "dhcpOptionsId";
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info = [];
        sub_info = popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info;
        if (dhcp.dhcpConfigurationSet) {
          _.map(dhcp.dhcpConfigurationSet.item, function(item, i) {
            return _.map(item.valueSet, function(it, j) {
              return sub_info.push({
                "key": ['dhcpConfigurationSet', 'item', i, 'valueSet', j],
                "show_key": item.key
              });
            });
          });
        }
        return me.parseSourceValue('DescribeDhcpOptions', dhcp, "bubble", null);
      },
      reRenderRegionResource: function() {
        var me;
        me = this;
        return me.trigger("REGION_RESOURCE_CHANGED", null);
      },
      _set_app_property: function(resource, resources, i, action) {
        if (resource.tagSet !== void 0) {
          _.map(resource.tagSet, function(tag) {
            if (tag.key === 'app') {
              resources[action][i].app = tag.value;
            }
            if (tag.key === 'Created by' && tag.value === owner) {
              resources[action][i].owner = tag.value;
            }
            return null;
          });
        }
        return null;
      },
      updateUnmanagedList: function() {
        var me, resources_keys, time_stamp;
        me = this;
        time_stamp = new Date().getTime() / 1000;
        unmanaged_list = {
          "time_stamp": time_stamp,
          "items": []
        };
        resources_keys = ['DescribeVolumes', 'DescribeLoadBalancers', 'DescribeInstances', 'DescribeVpnConnections', 'DescribeVpcs', 'DescribeAddresses'];
        if (resource_source) {
          _.map(resources_keys, function(value) {
            var cur_attr, cur_tag;
            cur_attr = resource_source[value];
            cur_tag = value;
            _.map(cur_attr, function(value) {
              var name;
              if (value.app === void 0) {
                name = value.tagSet ? value.tagSet.name : null;
                switch (cur_tag) {
                  case "DescribeVolumes":
                    if (!name) {
                      if (value.attachmentSet) {
                        if (value.attachmentSet.item) {
                          name = value.attachmentSet.item.device;
                        }
                      }
                    }
                    unmanaged_list.items.push({
                      'type': "Volume",
                      'name': (name ? name : value.volumeId),
                      'status': value.status,
                      'cost': 0.00,
                      'data-bubble-data': me.parseSourceValue(cur_tag, value, "unmanaged_bubble", name),
                      'data-modal-data': me.parseSourceValue(cur_tag, value, "detail", name)
                    });
                    break;
                  case "DescribeInstances":
                    unmanaged_list.items.push({
                      'type': "Instance",
                      'name': (name ? name : value.instanceId),
                      'status': value.instanceState.name,
                      'cost': 0.00,
                      'data-bubble-data': me.parseSourceValue(cur_tag, value, "unmanaged_bubble", name),
                      'data-modal-data': me.parseSourceValue(cur_tag, value, "detail", name)
                    });
                    break;
                  case "DescribeVpnConnections":
                    unmanaged_list.items.push({
                      'type': "VPN",
                      'name': (name ? name : value.vpnConnectionId),
                      'status': value.state,
                      'cost': 0.00,
                      'data-bubble-data': me.parseSourceValue(cur_tag, value, "unmanaged_bubble", name),
                      'data-modal-data': me.parseSourceValue(cur_tag, value, "detail", name)
                    });
                    break;
                  case "DescribeVpcs":
                    unmanaged_list.items.push({
                      'type': "VPC",
                      'name': (name ? name : value.vpcId),
                      'status': value.state,
                      'cost': 0.00,
                      'data-bubble-data': me.parseSourceValue(cur_tag, value, "unmanaged_bubble", name),
                      'data-modal-data': me.parseSourceValue(cur_tag, value, "detail", name)
                    });
                    break;
                }
              }
              return null;
            });
            return null;
          });
        }
        me.set('unmanaged_list', unmanaged_list);
        return null;
      },
      describeRegionAccountAttributesService: function(region) {
        var me;
        me = this;
        current_region = region;
        vpc_model.DescribeAccountAttributes({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), null, ["supported-platforms"]);
        vpc_model.once('VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', function(result) {
          var regionAttrSet;
          console.log('region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN');
          regionAttrSet = result.resolved_data[current_region].accountAttributeSet.item[0].attributeValueSet.item;
          if ($.type(regionAttrSet) === "array") {
            vpc_attrs_value = {
              'classic': 'Classic',
              'vpc': 'VPC'
            };
          } else {
            vpc_attrs_value = {
              'vpc': 'VPC'
            };
          }
          me.set('vpc_attrs', vpc_attrs_value);
          return null;
        });
        return null;
      },
      parseSourceValue: function(type, value, keys, name) {
        var cur_state, keys_to_parse, keys_type, me, parse_btns, parse_result, parse_sub_info, parse_table, state_key, status_keys, value_to_parse;
        me = this;
        keys_to_parse = null;
        value_to_parse = value;
        parse_result = '';
        parse_sub_info = '';
        parse_table = '';
        parse_btns = '';
        keys_type = keys;
        if (popup_key_set[keys]) {
          keys_to_parse = popup_key_set[keys_type][type];
        } else {
          keys_type = "unmanaged_bubble";
          keys_to_parse = popup_key_set[keys_type][type];
        }
        status_keys = keys_to_parse.status;
        if (status_keys) {
          state_key = status_keys[0];
          cur_state = value_to_parse[state_key];
          _.map(status_keys, function(value, key) {
            if (cur_state) {
              if (key > 0) {
                cur_state = cur_state[value];
                if ($.type(cur_state) === "array") {
                  cur_state = cur_state[0];
                }
                return null;
              }
            }
          });
          if (cur_state) {
            parse_result += '"status":"' + cur_state + '", ';
          }
        }
        if (keys_to_parse.title) {
          if (keys !== "detail") {
            if (name) {
              parse_result += '"title":"' + name;
              if (value_to_parse[keys_to_parse.title]) {
                parse_result += '-' + value_to_parse[keys_to_parse.title];
                parse_result += '", ';
              }
            } else {
              if (value_to_parse[keys_to_parse.title]) {
                parse_result += '"title":"';
                parse_result += value_to_parse[keys_to_parse.title];
                parse_result += '", ';
              }
            }
          } else if (keys === 'detail') {
            if (name) {
              parse_result += '"title":"' + name;
              if (value_to_parse[keys_to_parse.title]) {
                parse_result += '(' + value_to_parse[keys_to_parse.title];
                parse_result += ')", ';
              }
            } else {
              if (value_to_parse[keys_to_parse.title]) {
                parse_result += '"title":"';
                parse_result += value_to_parse[keys_to_parse.title];
                parse_result += '", ';
              }
            }
          }
        }
        _.map(keys_to_parse.sub_info, function(value) {
          var cur_key, cur_value, key_array, show_key;
          key_array = value.key;
          show_key = value.show_key;
          cur_key = key_array[0];
          cur_value = value_to_parse[cur_key];
          _.map(key_array, function(value, key) {
            if (cur_value) {
              if (key > 0) {
                cur_value = cur_value[value];
                return cur_value;
              }
            }
          });
          if (cur_value) {
            if ($.type(cur_value) === 'object' || $.type(cur_value) === 'array') {
              cur_value = me._genBubble(cur_value, show_key, true);
            }
            parse_sub_info += '"<dt>' + show_key + ': </dt><dd>' + cur_value + '</dd>", ';
          }
          return null;
        });
        if (parse_sub_info) {
          parse_sub_info = '"sub_info":[' + parse_sub_info;
          parse_sub_info = parse_sub_info.substring(0, parse_sub_info.length - 2);
          parse_sub_info += ']';
        }
        if (keys_to_parse.detail_table) {
          parse_table = me._parseTableValue(keys_to_parse.detail_table, value_to_parse);
          if (parse_table) {
            parse_table = '"detail_table":' + parse_table;
            if (parse_sub_info) {
              parse_sub_info = parse_sub_info + ', ' + parse_table;
            } else {
              parse_sub_info = parse_table;
            }
          }
        }
        if (keys_to_parse.btns) {
          parse_btns = me._parseBtnValue(keys_to_parse.btns, value_to_parse);
          if (parse_btns) {
            parse_btns = '"btns":' + parse_btns;
            if (parse_sub_info) {
              parse_sub_info = parse_sub_info + ', ' + parse_btns;
            } else {
              parse_sub_info = parse_btns;
            }
          }
        }
        if (parse_result) {
          parse_result = '{' + parse_result;
          if (parse_sub_info) {
            parse_result += parse_sub_info;
          } else {
            parse_result = parse_result.substring(0, parse_result.length - 2);
          }
          parse_result += '}';
        }
        return parse_result;
      },
      _genBubble: function(source, title, entry) {
        var bubble_end, bubble_front, is_str, lines, me, parse_sub_info, titles, tmp;
        me = this;
        parse_sub_info = "";
        if ($.isEmptyObject(source)) {
          return "";
        }
        if ($.type(source) === 'object') {
          tmp = [];
          _.map(source, function(value, key) {
            if (value !== null) {
              if ($.type(value) === 'string') {
                return tmp.push('\\"<dt>' + key + ': </dt><dd>' + value + '</dd>\\"');
              } else {
                return tmp.push(me._genBubble(value, title, false));
              }
            }
          });
          parse_sub_info = tmp.join(', ');
          if (entry) {
            bubble_front = '<a href=\\"javascript:void(0)\\" class=\\"bubble table-link\\" data-bubble-template=\\"bubbleRegionResourceInfo\\" data-bubble-data=';
            bubble_end = '>' + title + '</a>';
            parse_sub_info = " &apos;{\\\"title\\\": \\\"" + title + '\\\" , \\\"sub_info\\\":[' + parse_sub_info + "]}&apos; ";
            parse_sub_info = bubble_front + parse_sub_info + bubble_end;
          }
        }
        if ($.type(source) === 'array') {
          tmp = [];
          titles = [];
          is_str = false;
          _.map(source, function(value, index) {
            var current_title;
            current_title = title;
            if (value.deviceName !== void 0) {
              current_title = value.deviceName;
            } else if (value.networkInterfaceId !== void 0) {
              current_title = value.networkInterfaceId;
            } else if (value.InstanceId !== void 0) {
              current_title = value.InstanceId;
            } else if (value.Listener !== void 0) {
              current_title = 'Listener' + '-' + index;
            } else {
              current_title = title + '-' + index;
            }
            titles.push(current_title);
            if (value !== null) {
              if ($.type(value) === 'string') {
                is_str = true;
                return tmp.push(value);
              } else {
                return tmp.push(me._genBubble(value, current_title, false));
              }
            }
          });
          lines = [];
          if (entry) {
            if (!is_str) {
              _.map(tmp, function(line, index) {
                bubble_front = '<a href=\\"javascript:void(0)\\" class=\\"bubble table-link\\" data-bubble-template=\\"bubbleRegionResourceInfo\\" data-bubble-data=';
                bubble_end = '>' + titles[index] + '</a>';
                line = " &apos;{\\\"title\\\": \\\"" + titles[index] + '\\\" , \\\"sub_info\\\":[' + line + "]}&apos; ";
                line = bubble_front + line + bubble_end;
                return lines.push(line);
              });
            } else {
              lines = tmp;
            }
          } else {
            lines = tmp;
          }
          parse_sub_info = lines.join(', ');
        }
        return parse_sub_info;
      },
      _parseTableValue: function(keyes_set, value_set) {
        var detail_table, me, parse_table_result, table_date, table_set;
        me = this;
        parse_table_result = '';
        table_date = '';
        detail_table = [
          {
            "key": ["vgwTelemetry", "item"],
            "show_key": "VPN Tunnel",
            "count_name": "tunnel"
          }, {
            "key": ["outsideIpAddress"],
            "show_key": "IP Address"
          }, {
            "key": ["status"],
            "show_key": "Status"
          }, {
            "key": ["lastStatusChange"],
            "show_key": "Last Changed"
          }, {
            "key": ["statusMessage"],
            "show_key": "Detail"
          }
        ];
        table_set = value_set.vgwTelemetry;
        if (table_set) {
          table_set = table_set.item;
          if (table_set) {
            parse_table_result = '{ "th_set":[';
            _.map(keyes_set, function(value, key) {
              if (key !== 0) {
                parse_table_result += ',';
              }
              parse_table_result += '"';
              parse_table_result += me._parseEmptyValue(value.show_key);
              parse_table_result += '"';
              return null;
            });
            _.map(table_set, function(value, key) {
              var cur_key, cur_value;
              cur_key = key;
              cur_value = key + 1;
              parse_table_result += '], "tr';
              parse_table_result += cur_value;
              parse_table_result += '_set":[';
              _.map(keyes_set, function(value, key) {
                if (key !== 0) {
                  parse_table_result += ',"';
                  parse_table_result += me._parseEmptyValue(table_set[cur_key][value.key]);
                  parse_table_result += '"';
                } else {
                  parse_table_result += '"';
                  parse_table_result += me._parseEmptyValue(value.count_name);
                  parse_table_result += cur_value;
                  parse_table_result += '"';
                }
                return null;
              });
              return null;
            });
            parse_table_result += ']}';
          }
        }
        return parse_table_result;
      },
      _parseEmptyValue: function(val) {
        var result;
        result = val ? val : '';
        return result;
      },
      _parseBtnValue: function(keyes_set, value_set) {
        var btn_data, me, parse_btns_result;
        me = this;
        parse_btns_result = '';
        btn_data = '';
        _.map(keyes_set, function(value) {
          var dc_data, dc_filename, dc_parse, value_conf;
          btn_data = '';
          if (value.type === "download_configuration") {
            value_conf = value_set.customerGatewayConfiguration;
            if (value_conf) {
              value_conf = $.xml2json($.parseXML(value_conf));
              value_conf = value_conf.vpn_connection;
              dc_data = {
                vpnConnectionId: me._parseEmptyValue(value_conf['@attributes'].id),
                vpnGatewayId: me._parseEmptyValue(value_conf.vpn_gateway_id),
                customerGatewayId: me._parseEmptyValue(value_conf.customer_gateway_id),
                tunnel: []
              };
              _.map(value_conf.ipsec_tunnel, function(value, key) {
                var cur_array;
                cur_array = {};
                cur_array.number = key + 1;
                cur_array.ike_protocol_method = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.authentication_protocol);
                cur_array.ike_protocol_method = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.authentication_protocol);
                cur_array.ike_pre_shared_key = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.pre_shared_key, cur_array.ike_authentication_protocol_algorithm = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.authentication_protocol));
                cur_array.ike_encryption_protocol = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.encryption_protocol);
                cur_array.ike_lifetime = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.lifetime);
                cur_array.ike_mode = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.mode);
                cur_array.ike_perfect_forward_secrecy = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.perfect_forward_secrecy);
                cur_array.ipsec_protocol = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.protocol);
                cur_array.ipsec_authentication_protocol = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.authentication_protocol);
                cur_array.ipsec_encryption_protocol = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.encryption_protocol);
                cur_array.ipsec_lifetime = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.lifetime);
                cur_array.ipsec_mode = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.mode);
                cur_array.ipsec_perfect_forward_secrecy = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.perfect_forward_secrecy);
                cur_array.ipsec_interval = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.dead_peer_detection.interval);
                cur_array.ipsec_retries = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.dead_peer_detection.retries);
                cur_array.tcp_mss_adjustment = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.tcp_mss_adjustment);
                cur_array.clear_df_bit = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.clear_df_bit);
                cur_array.fragmentation_before_encryption = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.fragmentation_before_encryption);
                cur_array.customer_gateway_outside_address = me._parseEmptyValue(value_conf.ipsec_tunnel[key].customer_gateway.tunnel_outside_address.ip_address);
                cur_array.vpn_gateway_outside_address = me._parseEmptyValue(value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_outside_address.ip_address);
                cur_array.customer_gateway_inside_address = me._parseEmptyValue(value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.ip_address + '/' + value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.network_cidr);
                cur_array.vpn_gateway_inside_address = me._parseEmptyValue(value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_inside_address.ip_address + '/' + value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.network_cidr);
                cur_array.next_hop = me._parseEmptyValue(value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_inside_address.ip_address);
                dc_data.tunnel.push(cur_array);
                return null;
              });
              dc_filename = dc_data.vpnConnectionId ? dc_data.vpnConnectionId : 'download_configuration';
              dc_data = MC.template.configurationDownload(dc_data);
              dc_parse = '{"download":true,"filecontent":"';
              dc_parse += btoa(dc_data);
              dc_parse += '","filename":"';
              dc_parse += dc_filename;
              dc_parse += '","btnname":"';
              dc_parse += value.name;
              dc_parse += '"},';
              btn_data += dc_parse;
            }
          }
          if (btn_data) {
            btn_data = btn_data.substring(0, btn_data.length - 1);
            parse_btns_result += '[';
            parse_btns_result += btn_data;
            return parse_btns_result += ']';
          }
        });
        return parse_btns_result;
      },
      _cacheResource: function(resources) {
        if (resources.DescribeVpcs) {
          _.map(resources.DescribeVpcs, function(res, i) {
            MC.data.resource_list[current_region][res.vpcId] = res;
            return null;
          });
        }
        if (resources.DescribeInstances) {
          _.map(resources.DescribeInstances, function(res, i) {
            MC.data.resource_list[current_region][res.instanceId] = res;
            return null;
          });
        }
        if (resources.DescribeVolumes) {
          _.map(resources.DescribeVolumes, function(res, i) {
            MC.data.resource_list[current_region][res.volumeId] = res;
            return null;
          });
        }
        if (resources.DescribeAddresses) {
          _.map(resources.DescribeAddresses, function(res, i) {
            MC.data.resource_list[current_region][res.publicIp] = res;
            return null;
          });
        }
        if (resources.DescribeLoadBalancers) {
          _.map(resources.DescribeLoadBalancers, function(res, i) {
            MC.data.resource_list[current_region][res.LoadBalancerName] = res;
            return null;
          });
        }
        if (resources.DescribeVpnConnections) {
          _.map(resources.DescribeVpnConnections, function(res, i) {
            MC.data.resource_list[current_region][res.vpnConnectionId] = res;
            return null;
          });
        }
        if (resources.DescribeKeyPairs) {
          _.map(resources.DescribeKeyPairs.item, function(res, i) {
            MC.data.resource_list[current_region][res.keyFingerprint] = res;
            return null;
          });
        }
        if (resources.DescribeSecurityGroups) {
          _.map(resources.DescribeSecurityGroups.item, function(res, i) {
            MC.data.resource_list[current_region][res.groupId] = res;
            return null;
          });
        }
        if (resources.DescribeDhcpOptions) {
          _.map(resources.DescribeDhcpOptions.item, function(res, i) {
            MC.data.resource_list[current_region][res.dhcpOptionsId] = res;
            return null;
          });
        }
        if (resources.DescribeSubnets) {
          _.map(resources.DescribeSubnets.item, function(res, i) {
            MC.data.resource_list[current_region][res.subnetId] = res;
            return null;
          });
        }
        if (resources.DescribeRouteTables) {
          _.map(resources.DescribeRouteTables.item, function(res, i) {
            MC.data.resource_list[current_region][res.routeTableId] = res;
            return null;
          });
        }
        if (resources.DescribeNetworkAcls) {
          _.map(resources.DescribeNetworkAcls.item, function(res, i) {
            MC.data.resource_list[current_region][res.networkAclId] = res;
            return null;
          });
        }
        if (resources.DescribeNetworkInterfaces) {
          _.map(resources.DescribeNetworkInterfaces.item, function(res, i) {
            MC.data.resource_list[current_region][res.networkInterfaceId] = res;
            return null;
          });
        }
        if (resources.DescribeInternetGateways) {
          _.map(resources.DescribeInternetGateways.item, function(res, i) {
            MC.data.resource_list[current_region][res.internetGatewayId] = res;
            return null;
          });
        }
        if (resources.DescribeVpnGateways) {
          _.map(resources.DescribeVpnGateways.item, function(res, i) {
            MC.data.resource_list[current_region][res.vpnGatewayId] = res;
            return null;
          });
        }
        if (resources.DescribeCustomerGateways) {
          _.map(resources.DescribeCustomerGateways.item, function(res, i) {
            MC.data.resource_list[current_region][res.customerGatewayId] = res;
            return null;
          });
        }
        if (resources.DescribeAutoScalingGroups) {
          _.map(resources.DescribeAutoScalingGroups.item, function(res, i) {
            MC.data.resource_list[current_region][res.AutoScalingGroupName] = res;
            return null;
          });
        }
        if (resources.DescribeLaunchConfigurations) {
          _.map(resources.DescribeLaunchConfigurations.item, function(res, i) {
            MC.data.resource_list[current_region][res.LaunchConfigurationName] = res;
            return null;
          });
        }
        if (resources.DescribeNotificationConfigurations) {
          _.map(resources.DescribeNotificationConfigurations.item, function(res, i) {
            MC.data.resource_list[current_region][res.TopicARN + res.NotificationType] = res;
            return null;
          });
        }
        if (resources.DescribePolicies) {
          _.map(resources.DescribePolicies.item, function(res, i) {
            MC.data.resource_list[current_region][res.PolicyName] = res;
            return null;
          });
        }
        if (resources.DescribeScheduledActions) {
          _.map(resources.DescribeScheduledActions.item, function(res, i) {
            MC.data.resource_list[current_region][res.ScheduledActionName] = res;
            return null;
          });
        }
        if (resources.DescribeAlarms) {
          _.map(resources.DescribeAlarms.item, function(res, i) {
            MC.data.resource_list[current_region][res.AlarmNames] = res;
            return null;
          });
        }
        if (resources.ListSubscriptions) {
          _.map(resources.ListSubscriptions.item, function(res, i) {
            MC.data.resource_list[current_region][res.SubscriptionArn] = res;
            return null;
          });
        }
        if (resources.ListTopics) {
          _.map(resources.ListTopics.item, function(res, i) {
            MC.data.resource_list[current_region][res.TopicArn] = res;
            return null;
          });
        }
        return null;
      },
      setResource: function(resources, _region) {
        var ami_list, cgw_set, dhcp_set, lists, manage_instances_app, manage_instances_id, me, reg, vgw_set;
        this._cacheResource(resources);
        me = this;
        lists = {
          ELB: 0,
          EIP: 0,
          Instance: 0,
          VPC: 0,
          VPN: 0,
          Volume: 0
        };
        lists.Not_Used = {
          'EIP': 0,
          'Volume': 0
        };
        owner = atob($.cookie('usercode'));
        if (resources.DescribeLoadBalancers) {
          reg = /app-\w{8}/;
          _.map(resources.DescribeLoadBalancers, function(elb, i) {
            var reg_result;
            elb.region = _region;
            elb.detail = me.parseSourceValue('DescribeLoadBalancers', elb, "detail", null);
            if (!elb.Instances) {
              elb.state = '0 of 0 instances in service';
              elb.instance_state = [];
            } else {
              elb_model.DescribeInstanceHealth({
                sender: this
              }, $.cookie('usercode'), $.cookie('session_id'), _region, elb.LoadBalancerName);
              elb_model.once('ELB__DESC_INS_HLT_RETURN', function(result) {
                var health, instance, total, _i, _len, _ref;
                total = result.resolved_data.length;
                health = 0;
                _ref = result.resolved_data;
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  instance = _ref[_i];
                  if (instance.state === "InService") {
                    health++;
                  }
                }
                _.map(resources.DescribeLoadBalancers, function(elb, i) {
                  if (elb.LoadBalancerName === result.param[4]) {
                    resources.DescribeLoadBalancers[i].state = "" + health + " of " + total + " instances in service";
                    resources.DescribeLoadBalancers[i].instance_state = result.resolved_data;
                  }
                  return null;
                });
                me.reRenderRegionResource();
                return null;
              });
            }
            reg_result = elb.LoadBalancerName.match(reg);
            if (reg_result) {
              elb.app = reg_result;
            }
            return null;
          });
          if (!MC.data.resources.DescribeLoadBalancers) {
            MC.data.resources.DescribeLoadBalancers = [];
          }
          MC.data.resources.DescribeLoadBalancers = MC.data.resources.DescribeLoadBalancers.concat(resources.DescribeLoadBalancers);
          null;
        }
        if (MC.data.resources.DescribeLoadBalancers) {
          lists.ELB = MC.data.resources.DescribeLoadBalancers.length;
        }
        if (resources.DescribeAutoScalingGroups) {
          _.map(resources.DescribeAutoScalingGroups, function(asl, i) {
            asl.region = _region;
            asl.detail = me.parseSourceValue('DescribeAutoScalingGroups', asl, "detail", null);
            return null;
          });
          if (!MC.data.resources.DescribeAutoScalingGroups) {
            MC.data.resources.DescribeAutoScalingGroups = [];
          }
          MC.data.resources.DescribeAutoScalingGroups = MC.data.resources.DescribeAutoScalingGroups.concat(resources.DescribeAutoScalingGroups);
          null;
        }
        if (resources.DescribeAddresses) {
          _.map(resources.DescribeAddresses, function(eip, i) {
            eip.region = _region;
            if ($.isEmptyObject(eip.instanceId)) {
              lists.Not_Used.EIP++;
              resources.DescribeAddresses[i].instanceId = 'Not associated';
            }
            eip.detail = me.parseSourceValue('DescribeAddresses', eip, "detail", null);
            return null;
          });
          if (!MC.data.resources.DescribeAddresses) {
            MC.data.resources.DescribeAddresses = [];
          }
          MC.data.resources.DescribeAddresses = MC.data.resources.DescribeAddresses.concat(resources.DescribeAddresses);
          null;
        }
        if (MC.data.resources.DescribeAddresses) {
          lists.EIP = MC.data.resources.DescribeAddresses.length;
        }
        MC.data.resources.Not_Used.EIP += lists.Not_Used.EIP;
        lists.Not_Used.EIP = MC.data.resources.Not_Used.EIP;
        manage_instances_id = [];
        manage_instances_app = {};
        if (resources.DescribeInstances) {
          ami_list = [];
          _.map(resources.DescribeInstances, function(ins, i) {
            var is_managed;
            ins.region = _region;
            ins.app = '';
            ins.name = '';
            ins.created_by = '';
            ami_list.push(ins.imageId);
            ins.detail = me.parseSourceValue('DescribeInstances', ins, "detail", null);
            is_managed = false;
            if (ins.tagSet !== void 0) {
              _.map(ins.tagSet, function(value, key) {
                if (value) {
                  if (key === 'app') {
                    ins.app = value;
                    is_managed = true;
                    resources.DescribeInstances[i].app = value;
                  }
                  if (key === 'name') {
                    ins.name = value;
                    resources.DescribeInstances[i].host = value;
                  }
                  if (key === 'Created by') {
                    ins.created_by = value;
                    resources.DescribeInstances[i].owner = value;
                  }
                }
                return null;
              });
            }
            if (!resources.DescribeInstances[i].host) {
              resources.DescribeInstances[i].host = '';
            }
            return null;
          });
          _.map(resources.DescribeInstances, function(ins) {
            if (ins.app !== void 0) {
              manage_instances_id.push(ins.instanceId);
              manage_instances_app[ins.instanceId] = ins.app;
            }
            return null;
          });
          if (ami_list.length !== 0) {
            ami_model.DescribeImages({
              sender: this
            }, $.cookie('usercode'), $.cookie('session_id'), _region, ami_list);
            ami_model.once('EC2_AMI_DESC_IMAGES_RETURN', function(result) {
              var region_ami_list;
              region_ami_list = {};
              if ($.type(result.resolved_data.item) === 'array') {
                _.map(result.resolved_data.item, function(ami) {
                  region_ami_list[ami.imageId] = ami;
                  return null;
                });
              }
              _.map(resources.DescribeInstances, function(ins, i) {
                ins.image = region_ami_list[ins.imageId];
                return null;
              });
              me.reRenderRegionResource();
              return null;
            });
          }
          if (!MC.data.resources.DescribeInstances) {
            MC.data.resources.DescribeInstances = [];
          }
          MC.data.resources.DescribeInstances = MC.data.resources.DescribeInstances.concat(resources.DescribeInstances);
          null;
        }
        if (MC.data.resources.DescribeInstances) {
          lists.Instance = MC.data.resources.DescribeInstances.length;
        }
        if (resources.DescribeVolumes) {
          _.map(resources.DescribeVolumes, function(vol, i) {
            var attachment, _ref;
            vol.region = _region;
            vol.detail = me.parseSourceValue('DescribeVolumes', vol, "detail", null);
            if (vol.status === "available") {
              lists.Not_Used.Volume++;
            }
            me._set_app_property(vol, resources, i, 'DescribeVolumes');
            if (!vol.attachmentSet) {
              vol.attachmentSet = {
                item: []
              };
              attachment = {
                device: 'not-attached',
                status: 'not-attached'
              };
              vol.attachmentSet.item[0] = attachment;
            } else {
              if (vol.tagSet === void 0 && (_ref = vol.attachmentSet.item[0].instanceId, __indexOf.call(manage_instances_id, _ref) >= 0)) {
                resources.DescribeVolumes[i].app = manage_instances_app[vol.attachmentSet.item[0].instanceId];
                resources.DescribeVolumes[i].instanceId = vol.attachmentSet.item[0].instanceId;
                _.map(resources.DescribeInstances, function(ins) {
                  if (ins.instanceId === vol.attachmentSet.item[0].instanceId && ins.owner !== void 0) {
                    resources.DescribeVolumes[i].owner = ins.owner;
                  }
                  return null;
                });
              }
            }
            return null;
          });
          if (!MC.data.resources.DescribeVolumes) {
            MC.data.resources.DescribeVolumes = [];
          }
          MC.data.resources.DescribeVolumes = MC.data.resources.DescribeVolumes.concat(resources.DescribeVolumes);
          null;
        }
        if (MC.data.resources.DescribeVolumes) {
          lists.Volume = MC.data.resources.DescribeVolumes.length;
        }
        MC.data.resources.Not_Used.Volume += lists.Not_Used.Volume;
        lists.Not_Used.Volume = MC.data.resources.Not_Used.Volume;
        if (resources.DescribeVpcs) {
          _.map(resources.DescribeVpcs, function(vpc, i) {
            me._set_app_property(vpc, resources, i, 'DescribeVpcs');
            vpc.detail = me.parseSourceValue('DescribeVpcs', vpc, "detail", null);
            return null;
          });
          dhcp_set = [];
          _.map(resources.DescribeVpcs, function(vpc) {
            var _ref;
            if ((_ref = vpc.dhcpOptionsId, __indexOf.call(dhcp_set, _ref) < 0) && vpc.dhcpOptionsId !== 'default') {
              dhcp_set.push(vpc.dhcpOptionsId);
            }
            return null;
          });
          if (dhcp_set.length !== 0) {
            dhcp_model.DescribeDhcpOptions({
              sender: this
            }, $.cookie('usercode'), $.cookie('session_id'), _region, dhcp_set);
            dhcp_model.once('VPC_DHCP_DESC_DHCP_OPTS_RETURN', function(result) {
              dhcp_set = result.resolved_data.item;
              _.map(resources.DescribeVpcs, function(vpc) {
                if (vpc.dhcpOptionsId === 'default') {
                  vpc.dhcp = '{"title": "default", "sub_info" : ["<dt>DhcpOptionsId: </dt><dd>None</dd>"]}';
                }
                if ($.type(dhcp_set) === 'object') {
                  if (vpc.dhcpOptionsId === dhcp_set.dhcpOptionsId) {
                    vpc.dhcp = me._genDhcp(dhcp_set);
                  }
                } else {
                  _.map(dhcp_set, function(dhcp) {
                    if (vpc.dhcpOptionsId === dhcp.dhcpOptionsId) {
                      vpc.dhcp = me._genDhcp(dhcp);
                      return null;
                    }
                  });
                }
                return null;
              });
              me.reRenderRegionResource();
              return null;
            });
          }
          if (!MC.data.resources.DescribeVpcs) {
            MC.data.resources.DescribeVpcs = [];
          }
          MC.data.resources.DescribeVpcs = MC.data.resources.DescribeVpcs.concat(resources.DescribeVpcs);
          null;
        }
        if (MC.data.resources.DescribeVpcs) {
          lists.VPC = MC.data.resources.DescribeVpcs.length;
        }
        if (resources.DescribeVpnConnections) {
          _.map(resources.DescribeVpnConnections, function(vpn, i) {
            vpn.region = _region;
            me._set_app_property(vpn, resources, i, 'DescribeVpnConnections');
            vpn.detail = me.parseSourceValue('DescribeVpnConnections', vpn, "detail", null);
            return null;
          });
          cgw_set = [];
          vgw_set = [];
          _.map(resources.DescribeVpnConnections, function(vpn) {
            cgw_set.push(vpn.customerGatewayId);
            return vgw_set.push(vpn.vpnGatewayId);
          });
          if (cgw_set.length !== 0) {
            customergateway_model.DescribeCustomerGateways({
              sender: this
            }, $.cookie('usercode'), $.cookie('session_id'), _region, cgw_set);
            customergateway_model.once('VPC_CGW_DESC_CUST_GWS_RETURN', function(result) {
              cgw_set = result.resolved_data.item;
              _.map(resources.DescribeVpnConnections, function(vpn) {
                if ($.type(cgw_set) === 'object') {
                  vpn.cgw = me.parseSourceValue('DescribeCustomerGateways', cgw_set, "bubble", null);
                } else {
                  _.map(cgw_set, function(cgw) {
                    if (vpn.customerGatewayId === cgw.customerGatewayId) {
                      vpn.cgw = me.parseSourceValue('DescribeCustomerGateways', cgw, "bubble", null);
                    }
                    return null;
                  });
                }
                return null;
              });
              return me.reRenderRegionResource();
            });
          }
          if (vgw_set.length !== 0) {
            vpngateway_model.DescribeVpnGateways({
              sender: this
            }, $.cookie('usercode'), $.cookie('session_id'), _region, vgw_set);
            vpngateway_model.once('VPC_VGW_DESC_VPN_GWS_RETURN', function(result) {
              vgw_set = result.resolved_data.item;
              _.map(resources.DescribeVpnConnections, function(vpn) {
                if ($.type(vgw_set) === 'object') {
                  vpn.vgw = me.parseSourceValue('DescribeVpnGateways', vgw_set, "bubble", null);
                } else {
                  _.map(vgw_set, function(vgw) {
                    if (vpn.vpnGatewayId === vgw.vpnGatewayId) {
                      vpn.vgw = me.parseSourceValue('DescribeVpnGateways', vgw, "bubble", null);
                    }
                    return null;
                  });
                }
                return null;
              });
              return me.reRenderRegionResource();
            });
          }
          if (!MC.data.resources.DescribeVpnConnections) {
            MC.data.resources.DescribeVpnConnections = [];
          }
          MC.data.resources.DescribeVpnConnections = MC.data.resources.DescribeVpnConnections.concat(resources.DescribeVpnConnections);
          null;
        }
        if (MC.data.resources.DescribeVpnConnections) {
          lists.VPN = MC.data.resources.DescribeVpnConnections.length;
        }
        me.set('region_resource', MC.data.resources);
        return me.set('region_resource_list', lists);
      },
      describeAWSResourcesService: function(region) {
        var me, res_type, resources;
        me = this;
        current_region = region;
        res_type = constant.AWS_RESOURCE;
        resources = {};
        resources[res_type.INSTANCE] = {};
        resources[res_type.EIP] = {};
        resources[res_type.VOLUME] = {};
        resources[res_type.VPC] = {};
        resources[res_type.VPN] = {};
        resources[res_type.ELB] = {};
        resources[res_type.KP] = {};
        resources[res_type.SG] = {};
        resources[res_type.ACL] = {};
        resources[res_type.CGW] = {};
        resources[res_type.DHCP] = {};
        resources[res_type.ENI] = {};
        resources[res_type.IGW] = {};
        resources[res_type.RT] = {};
        resources[res_type.SUBNET] = {};
        resources[res_type.VGW] = {};
        resources[res_type.ASG] = {};
        resources[res_type.ASL_LC] = {};
        resources[res_type.ASL_NC] = {};
        resources[res_type.ASL_SP] = {};
        resources[res_type.ASL_SA] = {};
        resources[res_type.CLW] = {};
        resources[res_type.SNS_SUB] = {};
        resources[res_type.SNS_TOPIC] = {};
        return aws_model.resource({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), region, resources);
      },
      describeAWSStatusService: function(region) {
        var me;
        me = this;
        current_region = region;
        aws_model.status({
          sender: this
        }, $.cookie('usercode'), $.cookie('session_id'), null, null);
        aws_model.once('AWS_STATUS_RETURN', function(result) {
          var result_list, service_list;
          console.log('AWS_STATUS_RETURN');
          status_list = {
            red: 0,
            yellow: 0,
            info: 0
          };
          service_list = constant.SERVICE_REGION[current_region];
          result_list = result.resolved_data.current;
          _.map(result_list, function(value) {
            var cur_service, service_set, should_show_service;
            service_set = value;
            cur_service = service_set.service;
            should_show_service = false;
            _.map(service_list, function(value) {
              if (cur_service === value) {
                should_show_service = true;
              }
              return null;
            });
            if (should_show_service) {
              switch (service_set.status) {
                case '1':
                  status_list.red += 1;
                  return null;
                case '2':
                  status_list.yellow += 1;
                  return null;
                case '3':
                  status_list.info += 1;
                  return null;
                default:
                  return null;
              }
            }
          });
          me.set('status_list', status_list);
          return null;
        });
        return null;
      }
    });
    model = new RegionModel();
    return model;
  });

}).call(this);
