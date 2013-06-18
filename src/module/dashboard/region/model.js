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
        "DescribeVpcs": {},
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
              "key": ["networkInterfaceSet"],
              "show_key": "Network Interface"
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
              "show_key": "SvpcId"
            }, {
              "key": ["cidrBlock"],
              "show_key": "CIDR"
            }, {
              "key": ["instanceTenancy"],
              "show_key": "Tenancy"
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
          var ami, i, ins, region_ami_list, _i, _j, _len, _len1, _ref, _ref1;
          region_ami_list = {};
          if (result.resolved_data.item.constructor === Array) {
            _ref = result.resolved_data.item;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              ami = _ref[_i];
              region_ami_list[ami.imageId] = ami;
            }
          }
          _ref1 = resource_source.DescribeInstances;
          for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
            ins = _ref1[i];
            ins.image = region_ami_list[ins.imageId];
          }
          me.reRenderRegionResource();
          return null;
        });
        elb_model.on('ELB__DESC_INS_HLT_RETURN', function(result) {
          var elb, health, i, instance, total, _i, _j, _len, _len1, _ref, _ref1;
          console.error(result);
          total = result.resolved_data.length;
          health = 0;
          _ref = result.resolved_data;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            instance = _ref[_i];
            if (instance.state === "InService") {
              health++;
            }
          }
          _ref1 = resource_source.DescribeLoadBalancers;
          for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
            elb = _ref1[i];
            if (elb.LoadBalancerName === result.param[4]) {
              resource_source.DescribeLoadBalancers[i].state = "" + health + " of " + total + " instances in service";
            }
          }
          me.reRenderRegionResource();
          return null;
        });
        dhcp_model.on('VPC_DHCP_DESC_DHCP_OPTS_RETURN', function(result) {
          var dhcp, dhcp_set, vpc, _i, _j, _len, _len1, _ref;
          dhcp_set = result.resolved_data.item;
          console.error(dhcp_set);
          _ref = resource_source.DescribeVpcs;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            vpc = _ref[_i];
            if (dhcp_set.constructor === Object) {
              if (vpc.dhcpOptionsId === dhcp_set.dhcpOptionsId) {
                vpc.dhcp = me._genDhcp(dhcp_set);
              }
            } else {
              for (_j = 0, _len1 = dhcp_set.length; _j < _len1; _j++) {
                dhcp = dhcp_set[_j];
                if (vpc.dhcpOptionsId === dhcp.dhcpOptionsId) {
                  vpc.dhcp = me._genDhcp(dhcp);
                }
              }
            }
          }
          me.reRenderRegionResource();
          return null;
        });
        customergateway_model.on('VPC_CGW_DESC_CUST_GWS_RETURN', function(result) {
          var cgw, cgw_set, vpn, _i, _j, _len, _len1, _ref;
          cgw_set = result.resolved_data.item;
          _ref = resource_source.DescribeVpnConnections;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            vpn = _ref[_i];
            if (cgw_set.constructor === Object) {
              vpn.cgw = me.parseSourceValue('DescribeCustomerGateways', cgw_set, "bubble", null);
            } else {
              for (_j = 0, _len1 = cgw_set.length; _j < _len1; _j++) {
                cgw = cgw_set[_j];
                if (vpn.customerGatewayId === cgw.customerGatewayId) {
                  vpn.cgw = me.parseSourceValue('DescribeCustomerGateways', cgw, "bubble", null);
                }
              }
            }
          }
          return me.reRenderRegionResource();
        });
        vpngateway_model.on('VPC_VGW_DESC_VPN_GWS_RETURN', function(result) {
          var vgw, vgw_set, vpn, _i, _j, _len, _len1, _ref;
          vgw_set = result.resolved_data.item;
          _ref = resource_source.DescribeVpnConnections;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            vpn = _ref[_i];
            if (vgw_set.constructor === Object) {
              vpn.vgw = me.parseSourceValue('DescribeVpnGateways', vgw_set, "bubble", null);
            } else {
              for (_j = 0, _len1 = vgw_set.length; _j < _len1; _j++) {
                vgw = vgw_set[_j];
                if (vpn.vpnGatewayId === vgw.vpnGatewayId) {
                  vpn.vgw = me.parseSourceValue('DescribeVpnGateways', vgw, "bubble", null);
                }
              }
            }
          }
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
        var i, it, item, j, me, sub_info, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
        me = this;
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions = {};
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions.title = "dhcpOptionsId";
        popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info = [];
        sub_info = popup_key_set.unmanaged_bubble.DescribeDhcpOptions.sub_info;
        if (dhcp.dhcpConfigurationSet.item.constructor === Array) {
          _ref = dhcp.dhcpConfigurationSet.item;
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            item = _ref[i];
            if (item.valueSet.item.constructor === Array) {
              _ref1 = item.valueSet.item;
              for (j = _j = 0, _len1 = _ref1.length; _j < _len1; j = ++_j) {
                it = _ref1[j];
                sub_info.push({
                  "key": ['dhcpConfigurationSet', 'item', i, 'valueSet', 'item', j, 'value'],
                  "show_key": item.key
                });
              }
            } else {
              sub_info.push({
                "key": ['dhcpConfigurationSet', 'item', i, 'valueSet', 'item', 'value'],
                "show_key": item.key
              });
            }
          }
        } else {
          item = dhcp.dhcpConfigurationSet.item;
          if (item.valueSet.item.constructor === Array) {
            _ref2 = item.valueSet.item;
            for (i = _k = 0, _len2 = _ref2.length; _k < _len2; i = ++_k) {
              it = _ref2[i];
              sub_info.push({
                "key": ['dhcpConfigurationSet', 'item', 'valueSet', 'item', j, 'value'],
                "show_key": item.key
              });
            }
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
        var is_managed, tag, _i, _len, _ref;
        is_managed = false;
        if (resource.tagSet !== void 0 && resource.tagSet.item.constructor === Array) {
          _ref = resource.tagSet.item;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            tag = _ref[_i];
            if (tag.key === 'app') {
              is_managed = true;
              resources[action][i].app = tag.value;
            }
          }
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
            if (me.hasnotTagId(value.tagSet)) {
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
        }, $.cookie('usercode'), $.cookie('session_id'), current_region, ["supported-platforms"]);
        vpc_model.once('VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', function(result) {
          var regionAttrSet;
          console.log('region_VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN');
          regionAttrSet = result.resolved_data.accountAttributeSet.item.attributeValueSet.item;
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
      hasnotTagId: function(tagset) {
        if (tagset) {
          _.map(tagset, function(value) {
            if (value.key === "app-id" && value.value) {
              return false;
            }
          });
        }
        return true;
      },
      parseSourceValue: function(type, value, keys, name) {
        var cur_state, keys_to_parse, keys_type, parse_result, parse_sub_info, state_key, status_keys, value_to_parse;
        keys_to_parse = null;
        value_to_parse = value;
        parse_result = '';
        parse_sub_info = '';
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
                cur_state = cur_state.value;
                return cur_state;
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
            parse_sub_info += '"<dt>' + show_key + ': </dt><dd>' + cur_value + '</dd>", ';
          }
          return null;
        });
        if (parse_sub_info) {
          parse_sub_info = '"sub_info":[' + parse_sub_info;
          parse_sub_info = parse_sub_info.substring(0, parse_sub_info.length - 2);
          parse_sub_info += ']';
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
        console.log(parse_result);
        return parse_result;
      },
      setResource: function(resources) {
        var ami_list, cgw_set, dhcp_set, eip, elb, i, ins, is_managed, lists, manage_instances_app, manage_instances_id, me, reg, reg_result, tag, vgw_set, vol, vpc, vpn, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _len6, _len7, _len8, _len9, _m, _n, _o, _p, _q, _r, _ref, _ref1, _ref10, _ref11, _ref12, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
        me = this;
        lists = {};
        lists.Not_Used = {
          'EIP': 0,
          'Volume': 0
        };
        lists.ELB = resources.DescribeLoadBalancers.length;
        reg = /app-\w{8}/;
        _ref = resources.DescribeLoadBalancers;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          elb = _ref[i];
          if ($.isEmptyObject(elb.Instances)) {
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
        }
        lists.EIP = resources.DescribeAddresses.length;
        _ref1 = resources.DescribeAddresses;
        for (i = _j = 0, _len1 = _ref1.length; _j < _len1; i = ++_j) {
          eip = _ref1[i];
          if ($.isEmptyObject(eip.instanceId)) {
            lists.Not_Used.EIP++;
            resources.DescribeAddresses[i].instanceId = 'Not associated';
          }
          me._set_app_property(eip, resources, i, 'DescribeAddresses');
        }
        lists.Instance = resources.DescribeInstances.length;
        ami_list = [];
        _ref2 = resources.DescribeInstances;
        for (i = _k = 0, _len2 = _ref2.length; _k < _len2; i = ++_k) {
          ins = _ref2[i];
          ami_list.push(ins.imageId);
          is_managed = false;
          if (ins.tagSet !== void 0 && ins.tagSet.item.constructor === Array) {
            _ref3 = ins.tagSet.item;
            for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
              tag = _ref3[_l];
              if (tag.key === 'app') {
                is_managed = true;
                resources.DescribeInstances[i].app = tag.value;
              }
              if (tag.key === 'name') {
                resources.DescribeInstances[i].host = tag.value;
              }
            }
          }
          if (!is_managed) {
            resources.DescribeInstances[i].app = 'Unmanaged';
          }
          if (resources.DescribeInstances[i].host === void 0) {
            resources.DescribeInstances[i].host = 'Unmanaged';
          }
        }
        manage_instances_id = [];
        manage_instances_app = {};
        _ref4 = resources.DescribeInstances;
        for (_m = 0, _len4 = _ref4.length; _m < _len4; _m++) {
          ins = _ref4[_m];
          if (ins.app !== 'Unmanaged') {
            manage_instances_id.push(ins.instanceId);
            manage_instances_app[ins.instanceId] = ins.app;
          }
        }
        lists.Volume = resources.DescribeVolumes.length;
        _ref5 = resources.DescribeVolumes;
        for (i = _n = 0, _len5 = _ref5.length; _n < _len5; i = ++_n) {
          vol = _ref5[i];
          if (vol.status === "available") {
            lists.Not_Used.Volume++;
          }
          me._set_app_property(vol, resources, i, 'DescribeVolumes');
          if (((_ref6 = vol.attachmentSet.item) != null ? _ref6.device : void 0) == null) {
            vol.attachmentSet.item = {};
            vol.attachmentSet.item.device = 'Not Attached';
            vol.attachmentSet.item.status = 'Not Attached';
          } else {
            if (_ref7 = vol.attachmentSet.item.instanceId, __indexOf.call(manage_instances_id, _ref7) >= 0) {
              resources.DescribeVolumes[i].app = manage_instances_app[vol.attachmentSet.item.instanceId];
            }
          }
        }
        lists.VPC = resources.DescribeVpcs.length;
        _ref8 = resources.DescribeVpcs;
        for (i = _o = 0, _len6 = _ref8.length; _o < _len6; i = ++_o) {
          vpc = _ref8[i];
          me._set_app_property(vpc, resources, i, 'DescribeVpcs');
        }
        dhcp_set = [];
        _ref9 = resources.DescribeVpcs;
        for (_p = 0, _len7 = _ref9.length; _p < _len7; _p++) {
          vpc = _ref9[_p];
          if (_ref10 = vpc.dhcpOptionsId, __indexOf.call(dhcp_set, _ref10) < 0) {
            dhcp_set.push(vpc.dhcpOptionsId);
          }
        }
        if (dhcp_set) {
          dhcp_model.DescribeDhcpOptions({
            sender: this
          }, $.cookie('usercode'), $.cookie('session_id'), current_region, dhcp_set);
        }
        lists.VPN = resources.DescribeVpnConnections.length;
        _ref11 = resources.DescribeVpnConnections;
        for (i = _q = 0, _len8 = _ref11.length; _q < _len8; i = ++_q) {
          vpn = _ref11[i];
          me._set_app_property(vpn, resources, i, 'DescribeVpnConnections');
        }
        cgw_set = [];
        vgw_set = [];
        _ref12 = resources.DescribeVpnConnections;
        for (_r = 0, _len9 = _ref12.length; _r < _len9; _r++) {
          vpn = _ref12[_r];
          cgw_set.push(vpn.customerGatewayId);
          vgw_set.push(vpn.vpnGatewayId);
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
        console.error(resources);
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
        }, $.cookie('usercode'), $.cookie('session_id'), region, null);
        return aws_model.once('AWS_STATUS_RETURN', function(result) {
          var result_list;
          console.log('AWS_STATUS_RETURN');
          status_list = {
            red: 0,
            yellow: 0,
            info: 0
          };
          console.log(result.resolved_data);
          result_list = result.resolved_data.current;
          _.map(result_list, function(value) {
            switch (value.status) {
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
          });
          me.set('status_list', status_list);
          return null;
        });
      }
    });
    model = new RegionModel();
    return model;
  });

}).call(this);
