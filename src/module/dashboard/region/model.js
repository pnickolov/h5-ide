(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['backbone', 'jquery', 'underscore', 'aws_model', 'ami_model', 'elb_model', 'dhcp_model', 'vpngateway_model', 'customergateway_model', 'vpc_model', 'constant'], function(Backbone, $, _, aws_model, ami_model, elb_model, dhcp_model, vpngateway_model, customergateway_model, vpc_model, constant) {
    var RegionModel, current_region, model, popup_key_set, resource_source, status_list, unmanaged_list, update_timestamp, vpc_attrs_value;
    current_region = null;
    resource_source = null;
    vpc_attrs_value = null;
    unmanaged_list = null;
    status_list = null;
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
              "key": ["attachmentSet", "item", "device"],
              "show_key": "Device Name"
            }, {
              "key": ["snapshotId"],
              "show_key": "Snapshot ID"
            }, {
              "key": ["createTime"],
              "show_key": "Create Time"
            }, {
              "key": ["attachmentSet", "item", "attachTime"],
              "show_key": "Attach Name"
            }, {
              "key": ["attachmentSet", "item", "deleteOnTermination"],
              "show_key": "Delete On Termination"
            }, {
              "key": ["attachmentSet", "item", "instanceId"],
              "show_key": "Instance ID"
            }, {
              "key": ["status"],
              "show_key": "status"
            }, {
              "key": ["attachmentSet", "item", "status"],
              "show_key": "Attachment Status"
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
              "key": ["blockDeviceMapping", "item", "deleteOnTermination"],
              "show_key": "Termination Protection"
            }, {
              "key": ["blockDeviceMapping", "item", "status"],
              "show_key": "Shutdown Behavior"
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
              "key": ["blockDeviceMapping", "item", "deviceName"],
              "show_key": "Block Devices"
            }, {
              "key": ["groupSet", "item", "groupName"],
              "show_key": "Security Groups"
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
              "key": ["routes", "item", "source"],
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
              "key": ["ListenerDescriptions", "member", "Listener"],
              "show_key": "ListenerDescriptions"
            }, {
              "key": ["SecurityGroups"],
              "show_key": "SecurityGroups"
            }, {
              "key": ["Subnets"],
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
        }
      }
    };
    RegionModel = Backbone.Model.extend({
      defaults: {
        temp: null,
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
          console.log('AWS_RESOURCE_RETURN');
          resource_source = result.resolved_data[current_region];
          me.setResource(resource_source);
          me.updateUnmanagedList();
          return null;
        });
        ami_model.on('EC2_AMI_DESC_IMAGES_RETURN', function(result) {
          var region_ami_list;
          region_ami_list = {};
          if (result.resolved_data.item.constructor === Array) {
            _.map(result.resolved_data.item, function(ami) {
              region_ami_list[ami.imageId] = ami;
              return null;
            });
          }
          _.map(resource_source.DescribeInstances, function(ins, i) {
            ins.image = region_ami_list[ins.imageId];
            return null;
          });
          me.reRenderRegionResource();
          return null;
        });
        elb_model.on('ELB__DESC_INS_HLT_RETURN', function(result) {
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
          _.map(resource_source.DescribeLoadBalancers, function(elb, i) {
            if (elb.LoadBalancerName === result.param[4]) {
              resource_source.DescribeLoadBalancers[i].state = "" + health + " of " + total + " instances in service";
            }
            return null;
          });
          me.reRenderRegionResource();
          return null;
        });
        dhcp_model.on('VPC_DHCP_DESC_DHCP_OPTS_RETURN', function(result) {
          var dhcp_set;
          dhcp_set = result.resolved_data.item;
          _.map(resource_source.DescribeVpcs, function(vpc) {
            if (vpc.dhcpOptionsId === 'default') {
              vpc.dhcp = '{"title": "default", "sub_info" : ["<dt>DhcpOptionsId: </dt><dd>None</dd>"]}';
            }
            if (dhcp_set.constructor === Object) {
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
        customergateway_model.on('VPC_CGW_DESC_CUST_GWS_RETURN', function(result) {
          var cgw_set;
          cgw_set = result.resolved_data.item;
          _.map(resource_source.DescribeVpnConnections, function(vpn) {
            if (cgw_set.constructor === Object) {
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
        vpngateway_model.on('VPC_VGW_DESC_VPN_GWS_RETURN', function(result) {
          var vgw_set;
          vgw_set = result.resolved_data.item;
          _.map(resource_source.DescribeVpnConnections, function(vpn) {
            if (vgw_set.constructor === Object) {
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
        return null;
      },
      temp: function() {
        var me;
        me = this;
        return null;
      },
      _genDhcp: function(dhcp) {
        var item, me, sub_info;
        me = this;
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions = {};
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions.title = "dhcpOptionsId";
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info = [];
        sub_info = popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info;
        if (dhcp.dhcpConfigurationSet.item.constructor === Array) {
          _.map(dhcp.dhcpConfigurationSet.item, function(item, i) {
            if (item.valueSet.item.constructor === Array) {
              return _.map(item.valueSet.item, function(it, j) {
                return sub_info.push({
                  "key": ['dhcpConfigurationSet', 'item', i, 'valueSet', 'item', j, 'value'],
                  "show_key": item.key
                });
              });
            } else {
              return sub_info.push({
                "key": ['dhcpConfigurationSet', 'item', i, 'valueSet', 'item', 'value'],
                "show_key": item.key
              });
            }
          });
        } else {
          item = dhcp.dhcpConfigurationSet.item;
          if (item.valueSet.item.constructor === Array) {
            _.map(item.valueSet.item, function(it, i) {
              return sub_info.push({
                "key": ['dhcpConfigurationSet', 'item', 'valueSet', 'item', j, 'value'],
                "show_key": item.key
              });
            });
          } else {
            sub_info.push({
              "key": ['dhcpConfigurationSet', 'item', 'valueSet', 'item', 'value'],
              "show_key": item.key
            });
          }
        }
        return me.parseSourceValue('DescribeDhcpOptions', dhcp, "bubble", null);
      },
      reRenderRegionResource: function() {
        var me;
        me = this;
        return me.trigger("REGION_RESOURCE_CHANGED", null);
      },
      _set_app_property: function(resource, resources, i, action) {
        var is_managed;
        is_managed = false;
        if (resource.tagSet !== void 0 && resource.tagSet.item.constructor === Array) {
          _.map(resource.tagSet.item, function(tag) {
            if (tag.key === 'app') {
              is_managed = true;
              resources[action][i].app = tag.value;
              return null;
            }
          });
        }
        if (!is_managed) {
          resources[action][i].app = 'Unmanaged';
        }
        return null;
      },
      updateUnmanagedList: function() {
        var me, resources_keys, time_stamp;
        me = this;
        time_stamp = new Date().getTime() / 1000;
        unmanaged_list = {};
        unmanaged_list.time_stamp = time_stamp;
        unmanaged_list.items = [];
        resources_keys = ['DescribeVolumes', 'DescribeLoadBalancers', 'DescribeInstances', 'DescribeVpnConnections', 'DescribeVpcs', 'DescribeAddresses'];
        console.log(resource_source);
        _.map(resources_keys, function(value) {
          var cur_attr, cur_tag;
          cur_attr = resource_source[value];
          cur_tag = value;
          _.map(cur_attr, function(value) {
            var name;
            if (value.app === "Unmanaged") {
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
        vpc_model.on('VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', function(result) {
          var regionAttrSet;
          console.log('region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN');
          regionAttrSet = result.resolved_data[current_region].accountAttributeSet.item.attributeValueSet.item;
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
          keys_type = 'unmanaged_bubble';
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
                return null;
              }
            }
          });
          if (cur_state) {
            parse_result += '"status":"' + cur_state + '", ';
          }
        }
        if (keys_to_parse.title) {
          if (keys === 'unmanaged_bubble' || 'bubble') {
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
            if (cur_value.constructor === Object || cur_value.constructor === Array) {
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
        var bubble_end, bubble_front, me, parse_sub_info, tmp;
        me = this;
        parse_sub_info = "";
        if ($.isEmptyObject(source)) {
          return "";
        }
        if (source.constructor === Object) {
          tmp = [];
          _.map(source, function(value, key) {
            if (value !== null) {
              if (value.constructor === String) {
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
        if (source.constructor === Array) {
          tmp = [];
          _.map(source, function(value) {
            if (value !== null) {
              if (value.constructor === String) {
                return tmp.push(value);
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
        return parse_sub_info;
      },
      _parseTableValue: function(keyes_set, value_set) {
        var count_set, detail_table, me, parse_table_result, table_date, table_set;
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
            count_set = [1, 2];
            _.map(count_set, function(value, key) {
              var cur_key, cur_value;
              cur_key = key;
              cur_value = value;
              parse_table_result += '], "tr';
              parse_table_result += cur_value;
              parse_table_result += '_set":[';
              _.map(keyes_set, function(value, key) {
                if (key !== 0) {
                  parse_table_result += ',';
                  parse_table_result += '"';
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
          var count_set, dc_data, dc_filename, dc_parse, value_conf;
          btn_data = '';
          if (value.type === "download_configuration") {
            value_conf = value_set.customerGatewayConfiguration;
            if (value_conf) {
              value_conf = $.xml2json($.parseXML(value_conf));
              value_conf = value_conf.vpn_connection;
              dc_data = {
                vpnConnectionId: me._parseEmptyValue(value_conf['@attributes'].id),
                vpnGatewayId: me._parseEmptyValue(value_conf.vpn_gateway_id),
                customerGatewayId: me._parseEmptyValue(value_conf.customer_gateway_id)
              };
              count_set = [1, 2];
              _.map(count_set, function(value, key) {
                dc_data["tunnel" + key + "_ike_protocol_method"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.authentication_protocol);
                dc_data["tunnel" + key + "_ike_protocol_method"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.authentication_protocol);
                dc_data["tunnel" + key + "_ike_pre_shared_key"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.pre_shared_key, dc_data["tunnel" + key + "_ike_authentication_protocol_algorithm"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.authentication_protocol));
                dc_data["tunnel" + key + "_ike_encryption_protocol"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.encryption_protocol);
                dc_data["tunnel" + key + "_ike_lifetime"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.lifetime);
                dc_data["tunnel" + key + "_ike_mode"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.mode);
                dc_data["tunnel" + key + "_ike_perfect_forward_secrecy"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ike.perfect_forward_secrecy);
                dc_data["tunnel" + key + "_ipsec_protocol"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.protocol);
                dc_data["tunnel" + key + "_ipsec_authentication_protocol"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.authentication_protocol);
                dc_data["tunnel" + key + "_ipsec_encryption_protocol"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.encryption_protocol);
                dc_data["tunnel" + key + "_ipsec_lifetime"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.lifetime);
                dc_data["tunnel" + key + "_ipsec_mode"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.mode);
                dc_data["tunnel" + key + "_ipsec_perfect_forward_secrecy"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.perfect_forward_secrecy);
                dc_data["tunnel" + key + "_ipsec_interval"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.dead_peer_detection.interval);
                dc_data["tunnel" + key + "_ipsec_retries"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.dead_peer_detection.retries);
                dc_data["tunnel" + key + "_tcp_mss_adjustment"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.tcp_mss_adjustment);
                dc_data["tunnel" + key + "_clear_df_bit"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.clear_df_bit);
                dc_data["tunnel" + key + "_fragmentation_before_encryption"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].ipsec.fragmentation_before_encryption);
                dc_data["tunnel" + key + "_customer_gateway_outside_address"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].customer_gateway.tunnel_outside_address.ip_address);
                dc_data["tunnel" + key + "_vpn_gateway_outside_address"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_outside_address.ip_address);
                dc_data["tunnel" + key + "_customer_gateway_inside_address"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.ip_address + '/' + value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.network_cidr);
                dc_data["tunnel" + key + "_vpn_gateway_inside_address"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_inside_address.ip_address + '/' + value_conf.ipsec_tunnel[key].customer_gateway.tunnel_inside_address.network_cidr);
                dc_data["tunnel" + key + "_next_hop"] = me._parseEmptyValue(value_conf.ipsec_tunnel[key].vpn_gateway.tunnel_inside_address.ip_address);
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
      setResource: function(resources) {
        var ami_list, cgw_set, dhcp_set, lists, manage_instances_app, manage_instances_id, me, reg, vgw_set;
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
        if (resources.DescribeLoadBalancers !== null) {
          lists.ELB = resources.DescribeLoadBalancers.length;
          reg = /app-\w{8}/;
          _.map(resources.DescribeLoadBalancers, function(elb, i) {
            var reg_result;
            elb.detail = me.parseSourceValue('DescribeLoadBalancers', elb, "detail", null);
            if (!elb.Instances) {
              elb.state = '0 of 0 instances in service';
            } else {
              elb_model.DescribeInstanceHealth({
                sender: this
              }, $.cookie('usercode'), $.cookie('session_id'), current_region, elb.LoadBalancerName);
            }
            reg_result = elb.LoadBalancerName.match(reg);
            if (reg_result) {
              elb.app = reg_result;
            } else {
              elb.app = 'Unmanaged';
            }
            return null;
          });
        }
        if (resources.DescribeAddresses !== null) {
          _.map(resources.DescribeAddresses, function(eip, i) {
            if ($.isEmptyObject(eip.instanceId)) {
              lists.Not_Used.EIP++;
              resources.DescribeAddresses[i].instanceId = 'Not associated';
            }
            me._set_app_property(eip, resources, i, 'DescribeAddresses');
            eip.detail = me.parseSourceValue('DescribeAddresses', eip, "detail", null);
            return null;
          });
          lists.EIP = resources.DescribeAddresses.length;
        }
        if (resources.DescribeInstances !== null) {
          lists.Instance = resources.DescribeInstances.length;
          ami_list = [];
          _.map(resources.DescribeInstances, function(ins, i) {
            var delete_index, is_managed, j, _i, _len;
            ami_list.push(ins.imageId);
            delete_index = [];
            if (ins.networkInterfaceSet) {
              _.map(ins.networkInterfaceSet.item, function(eni, eni_index) {
                return delete_index.push(popup_key_set.detail.DescribeInstances.sub_info.push({
                  "key": ['networkInterfaceSet', 'item', eni_index],
                  "show_key": "NetworkInterface-" + eni_index
                }));
              });
            }
            ins.detail = me.parseSourceValue('DescribeInstances', ins, "detail", null);
            for (_i = 0, _len = delete_index.length; _i < _len; _i++) {
              j = delete_index[_i];
              popup_key_set.detail.DescribeInstances.sub_info.pop();
            }
            is_managed = false;
            if (ins.tagSet !== void 0 && ins.tagSet.item.constructor === Array) {
              _.map(ins.tagSet.item, function(tag) {
                if (tag.key === 'app') {
                  is_managed = true;
                  resources.DescribeInstances[i].app = tag.value;
                }
                if (tag.key === 'name') {
                  resources.DescribeInstances[i].host = tag.value;
                }
                return null;
              });
            }
            if (!is_managed) {
              resources.DescribeInstances[i].app = 'Unmanaged';
            }
            if (resources.DescribeInstances[i].host === void 0) {
              resources.DescribeInstances[i].host = 'Unmanaged';
            }
            return null;
          });
          manage_instances_id = [];
          manage_instances_app = {};
          _.map(resources.DescribeInstances, function(ins) {
            if (ins.app !== 'Unmanaged') {
              manage_instances_id.push(ins.instanceId);
              manage_instances_app[ins.instanceId] = ins.app;
            }
            return null;
          });
        }
        lists.Volume = resources.DescribeVolumes.length;
        _.map(resources.DescribeVolumes, function(vol, i) {
          var attachment, _ref;
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
            if (_ref = vol.attachmentSet.item.instanceId, __indexOf.call(manage_instances_id, _ref) >= 0) {
              resources.DescribeVolumes[i].app = manage_instances_app[vol.attachmentSet.item.instanceId];
            }
          }
          return null;
        });
        if (resources.DescribeVpcs !== null) {
          lists.VPC = resources.DescribeVpcs.length;
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
          if (dhcp_set) {
            dhcp_model.DescribeDhcpOptions({
              sender: this
            }, $.cookie('usercode'), $.cookie('session_id'), current_region, dhcp_set);
          }
        }
        if (resources.DescribeVpnConnections !== null) {
          lists.VPN = resources.DescribeVpnConnections.length;
          _.map(resources.DescribeVpnConnections, function(vpn, i) {
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
        }
        if (cgw_set) {
          customergateway_model.DescribeCustomerGateways({
            sender: this
          }, $.cookie('usercode'), $.cookie('session_id'), current_region, cgw_set);
        }
        if (vgw_set) {
          vpngateway_model.DescribeVpnGateways({
            sender: this
          }, $.cookie('usercode'), $.cookie('session_id'), current_region, vgw_set);
        }
        if (ami_list) {
          ami_model.DescribeImages({
            sender: this
          }, $.cookie('usercode'), $.cookie('session_id'), current_region, ami_list);
        }
        console.log(resources);
        me.set('region_resource', resources);
        return me.set('region_resource_list', lists);
      },
      describeAWSResourcesService: function(region) {
        var me, resources;
        me = this;
        current_region = region;
        resources = [constant.AWS_RESOURCE.INSTANCE, constant.AWS_RESOURCE.EIP, constant.AWS_RESOURCE.VOLUME, constant.AWS_RESOURCE.VPC, constant.AWS_RESOURCE.VPN, constant.AWS_RESOURCE.ELB];
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
        aws_model.on('AWS_STATUS_RETURN', function(result) {
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
