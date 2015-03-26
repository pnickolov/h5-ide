
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["OpsModel", "ApiRequest", "constant" ], ( OpsModel, ApiRequest, constant )->

  AwsOpsModel = OpsModel.extend {

    type : OpsModel.Type.Amazon

    getMsrId : ()->
      msrId = OpsModel.prototype.getMsrId.call this
      if msrId then return msrId
      if not @__jsonData then return undefined
      for uid, comp of @__jsonData.component
        if comp.type is constant.RESTYPE.VPC
          return comp.resource.VpcId
      undefined

    __defaultJson : ()->
      jsonType = @getJsonType()
      if jsonType is "aws"
        @___defaultJson()
      else
        @___mesosJson()

    ___defaultJson : ()->
      json   = OpsModel.prototype.__defaultJson.call this
      vpcId  = MC.guid()
      vpcRef = "@{#{vpcId}.resource.VpcId}"

      layout =
        VPC :
          coordinate : [5,3]
          size       : [60,60]
        RTB :
          coordinate : [50,5]
          groupUId   : vpcId

      component =
        KP :
          type : "AWS.EC2.KeyPair"
          name : "DefaultKP"
          resource : {
            KeyName : "DefaultKP"
            KeyFingerprint : ""
          }
        SG :
          type : "AWS.EC2.SecurityGroup"
          name : "DefaultSG"
          resource :
            IpPermissions: [{
              IpProtocol : "tcp",
              IpRanges   : "0.0.0.0/0",
              FromPort   : "22",
              ToPort     : "22",
            }],
            IpPermissionsEgress : [{
              FromPort: "0",
              IpProtocol: "-1",
              IpRanges: "0.0.0.0/0",
              ToPort: "65535"
            }],
            Default          : true
            GroupId          : ""
            GroupName        : "DefaultSG"
            GroupDescription : 'default VPC security group'
            VpcId            : vpcRef
        ACL :
          type : "AWS.VPC.NetworkAcl"
          name : "DefaultACL"
          resource :
            AssociationSet : []
            Default        : true
            NetworkAclId   : ""
            VpcId          : vpcRef
            EntrySet : [
              {
                RuleAction : "allow"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : true
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 100
              }
              {
                RuleAction : "allow"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : false
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 100
              }
              {
                RuleAction : "deny"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : true
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 32767
              }
              {
                RuleAction : "deny"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : false
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 32767
              }
            ]
        VPC :
          type : "AWS.VPC.VPC"
          name : "vpc"
          resource :
            VpcId              : ""
            CidrBlock          : "10.0.0.0/16"
            DhcpOptionsId      : ""
            EnableDnsHostnames : false
            EnableDnsSupport   : true
            InstanceTenancy    : "default"
        RTB :
          type : "AWS.VPC.RouteTable"
          name : "RT-0"
          resource :
            VpcId : vpcRef
            RouteTableId: ""
            AssociationSet : [{
              Main:"true"
              SubnetId : ""
              RouteTableAssociationId : ""
            }]
            PropagatingVgwSet:[]
            RouteSet : [{
              InstanceId           : ""
              NetworkInterfaceId   : ""
              Origin               : 'CreateRouteTable'
              GatewayId            : 'local'
              DestinationCidrBlock : '10.0.0.0/16'
            }]

      # Generate new GUID for each component
      for id, comp of component
        if id is "VPC"
          comp.uid = vpcId
        else
          comp.uid = MC.guid()
        json.component[ comp.uid ] = comp
        if layout[ id ]
          l = layout[id]
          l.uid = comp.uid
          json.layout[ comp.uid ] = l

      json

    ___mesosJson: ()->
      json   = OpsModel.prototype.__defaultJson.call this

      amiForEachRegion = [
        {"region":"#{regionName}","imageId":"ami-9ef278f6"}
        {"region":"us-west-1","imageId":"ami-353f2970"}
        {"region":"eu-west-1","imageId":"ami-1a92266d"}
        {"region":"us-west-2","imageId":"ami-fba3e8cb"}
        {"region":"eu-central-1","imageId":"ami-929caa8f"}
        {"region":"ap-southeast-2","imageId":"ami-5fe28d65"}
        {"region":"ap-northeast-1","imageId":"ami-9d7f479c"}
        {"region":"ap-southeast-1","imageId":"ami-a6a083f4"}
        {"region":"sa-east-1","imageId":"ami-c79e28da"}
      ]

      imageId = (_.findWhere amiForEachRegion, {region: @get("region")}).imageId
      regionName = @get("region")

      component = {
        "8CEA58B4-197E-4A54-B490-8EFC45582DBB": {
          "name": "DefaultACL",
          "type": "AWS.VPC.NetworkAcl",
          "uid": "8CEA58B4-197E-4A54-B490-8EFC45582DBB",
          "resource": {
            "AssociationSet": [{
              "NetworkAclAssociationId": "",
              "SubnetId": "@{FABDEDD1-E3D6-4B58-9963-680A2DD52A72.resource.SubnetId}"
            }, {
              "NetworkAclAssociationId": "",
              "SubnetId": "@{BA041E65-6720-4FD2-AD73-993DC0DF6C79.resource.SubnetId}"
            }, {
              "NetworkAclAssociationId": "",
              "SubnetId": "@{6BE3D1A2-1233-4A86-AC11-B944B9E34CBF.resource.SubnetId}"
            }, {
              "NetworkAclAssociationId": "",
              "SubnetId": "@{827F9D8A-F900-44C8-833E-D20628BF8DF5.resource.SubnetId}"
            }],
            "Default": true,
            "EntrySet": [{
              "Egress": true,
              "Protocol": -1,
              "RuleAction": "allow",
              "RuleNumber": 100,
              "CidrBlock": "0.0.0.0/0",
              "IcmpTypeCode": {
                "Code": "",
                "Type": ""
              },
              "PortRange": {
                "From": "",
                "To": ""
              }
            }, {
              "Egress": false,
              "Protocol": -1,
              "RuleAction": "allow",
              "RuleNumber": 100,
              "CidrBlock": "0.0.0.0/0",
              "IcmpTypeCode": {
                "Code": "",
                "Type": ""
              },
              "PortRange": {
                "From": "",
                "To": ""
              }
            }, {
              "Egress": true,
              "Protocol": -1,
              "RuleAction": "deny",
              "RuleNumber": 32767,
              "CidrBlock": "0.0.0.0/0",
              "IcmpTypeCode": {
                "Code": "",
                "Type": ""
              },
              "PortRange": {
                "From": "",
                "To": ""
              }
            }, {
              "Egress": false,
              "Protocol": -1,
              "RuleAction": "deny",
              "RuleNumber": 32767,
              "CidrBlock": "0.0.0.0/0",
              "IcmpTypeCode": {
                "Code": "",
                "Type": ""
              },
              "PortRange": {
                "From": "",
                "To": ""
              }
            }],
            "NetworkAclId": "",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "Tags": [{
              "Key": "visops_default",
              "Value": "true"
            }]
          }
        },
        "520A015A-0902-4E85-8F49-F8F86665C360": {
          "name": "RT-0",
          "description": "",
          "type": "AWS.VPC.RouteTable",
          "uid": "520A015A-0902-4E85-8F49-F8F86665C360",
          "resource": {
            "PropagatingVgwSet": [],
            "RouteTableId": "",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "AssociationSet": [{
              "Main": "true",
              "RouteTableAssociationId": "",
              "SubnetId": ""
            }],
            "RouteSet": [{
              "Origin": "CreateRouteTable",
              "DestinationCidrBlock": "10.0.0.0/16",
              "InstanceId": "",
              "NetworkInterfaceId": "",
              "GatewayId": "local"
            }, {
              "DestinationCidrBlock": "0.0.0.0/0",
              "Origin": "",
              "InstanceId": "",
              "NetworkInterfaceId": "",
              "GatewayId": "@{99392B0D-12F0-47ED-958F-6E0F9D0B5C28.resource.InternetGatewayId}"
            }],
            "Tags": [{
              "Key": "visops_default",
              "Value": "true"
            }]
          }
        },
        "2D221BC2-A50B-42CA-97CE-CBF5E7C6668E": {
          "name": "mesos",
          "description": "",
          "type": "AWS.VPC.VPC",
          "uid": "2D221BC2-A50B-42CA-97CE-CBF5E7C6668E",
          "resource": {
            "EnableDnsSupport": true,
            "InstanceTenancy": "default",
            "EnableDnsHostnames": false,
            "DhcpOptionsId": "",
            "VpcId": "",
            "CidrBlock": "10.0.0.0/16"
          }
        },
        "47C1B56E-E96C-418B-8F38-5BCEEE95BC18": {
          "type": "AWS.AutoScaling.LaunchConfiguration",
          "uid": "47C1B56E-E96C-418B-8F38-5BCEEE95BC18",
          "name": "slave-lc-0",
          "description": "",
          "state": [{
            "parameter": {
              "comment": "---- pkg ----"
            },
            "id": "state-2445B4E7-741A-46D1-997E-BF2005B11BC6",
            "module": "meta.comment"
          }, {
            "parameter": {
              "cmd": "apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF"
            },
            "id": "state-324B5FB2-4455-4F85-9DF9-1406DB3DD8D2",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "cmd": "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9"
            },
            "id": "state-C19B9B58-10C3-49FD-A44A-81C7D6523A67",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "content": "deb https://get.docker.com/ubuntu docker main",
              "name": "docker"
            },
            "id": "state-0F88F93F-A903-405B-AE1A-3B16E18F14ED",
            "module": "linux.apt.repo"
          }, {
            "parameter": {
              "content": "deb http://repos.mesosphere.io/ubuntu trusty main",
              "name": "mesos"
            },
            "id": "state-08FC9E2D-FFDE-4DD4-AC21-74686E63FCD8",
            "module": "linux.apt.repo"
          }, {
            "parameter": {
              "name": [{
                "key": "mesos",
                "value": ""
              }, {
                "key": "zookeeper",
                "value": "purged"
              }, {
                "key": "haproxy",
                "value": ""
              }, {
                "key": "apt-transport-https",
                "value": ""
              }, {
                "key": "lxc-docker",
                "value": ""
              }]
            },
            "id": "state-EDF0F631-1783-4DD4-867F-4942BC2EE2EA",
            "module": "linux.apt.package"
          }, {
            "parameter": {
              "comment": "---- HA proxy ----"
            },
            "id": "state-04923904-B053-4584-9D72-16432A26F4F2",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "127.0.0.1 localhost\n\n@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress} master1\n@{2286840C-58C1-4A0A-B592-20B62381D448.PrivateIpAddress} master2\n@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress} master3\n\n# The following lines are desirable for IPv6 capable hosts\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\nff02::3 ip6-allhosts\n",
              "path": "/etc/hosts"
            },
            "id": "state-8ABAE0D0-DAFD-4706-B444-5E5EF82130AB",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "# Set ENABLED to 1 if you want the init script to start haproxy.\nENABLED=1\n# Add extra flags here.\n#EXTRAOPTS=\"-de -m 16\"\n",
              "path": "/etc/default/haproxy"
            },
            "id": "state-E3EF94B3-A6B9-419F-86F5-A42ADCBC8FCB",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "#!/bin/bash\nset -o errexit -o nounset -o pipefail\nfunction -h {\ncat <<USAGE\n USAGE: $name <marathon host:port>+\n        $name install_haproxy_system <marathon host:port>+\n\n  Generates a new configuration file for HAProxy from the specified Marathon\n  servers, replaces the file in /etc/haproxy and restarts the service.\n\n  In the second form, installs the script itself, HAProxy and a cronjob that\n  once a minute pings one of the Marathon servers specified and refreshes\n  HAProxy if anything has changed. The list of Marathons to ping is stored,\n  one per line, in:\n\n    $cronjob_conf_file\n\n  The script is installed as:\n\n    $script_path\n\n  The cronjob is installed as:\n\n    $cronjob\n\n  and run as root.\n\nUSAGE\n}; function --help { -h ;}\nexport LC_ALL=en_US.UTF-8\n\nname=haproxy-marathon-bridge\ncronjob_conf_file=/etc/\"$name\"/marathons\ncronjob=/etc/cron.d/\"$name\"\nscript_path=/usr/local/bin/\"$name\"\nconf_file=haproxy.cfg\n\nfunction main {\n  config \"$@\"\n}\n\nfunction refresh_system_haproxy {\n  config \"$@\" > /tmp/\"$conf_file\"\n  if ! diff -q /tmp/\"$conf_file\" /etc/haproxy/\"$conf_file\" >&2\n  then\n    msg \"Found changes. Sending reload request to HAProxy...\"\n    cat /tmp/\"$conf_file\" > /etc/haproxy/\"$conf_file\"\n    if [[ -f /etc/init/haproxy.conf ]]\n    then reload haproxy ## Upstart\n    elif [[ -f /usr/lib/systemd/system/haproxy.service ]]\n    then systemctl reload haproxy ## systemd\n    else /etc/init.d/haproxy reload\n    fi\n  fi\n}\n\nfunction install_haproxy_system {\n\n  if hash lsb_release 2>/dev/null\n  then\n    os=$(lsb_release -si)\n  elif [ -e \"/etc/system-release\" ] && (grep -q \"Amazon Linux AMI\" \"/etc/system-release\")\n  then\n    os=\"AmazonAMI\"\n  fi\n\n  if [[ $os == \"CentOS\" ]] || [[ $os == \"RHEL\" ]] || [[ $os == \"AmazonAMI\" ]]\n  then\n    sudo yum install -y haproxy\n    sudo chkconfig haproxy on\n  elif [[ $os == \"Ubuntu\" ]] || [[ $os == \"Debian\" ]]\n  then\n    sudo env DEBIAN_FRONTEND=noninteractive aptitude install -y haproxy\n    sudo sed -i 's/^ENABLED=0/ENABLED=1/' /etc/default/haproxy\n  else\n    echo \"$os is not a supported OS for this feature.\"\n    exit 1\n  fi\n  install_cronjob \"$@\"\n}\n\nfunction install_cronjob {\n  sudo mkdir -p \"$(dirname \"$cronjob_conf_file\")\"\n  [[ -f $cronjob_conf_file ]] || sudo touch \"$cronjob_conf_file\"\n  if [[ $# -gt 0 ]]\n  then printf '%s\\n' \"$@\" | sudo dd of=\"$cronjob_conf_file\"\n  fi\n  cat \"$0\" | sudo dd of=\"$script_path\"\n  sudo chmod ug+rx \"$script_path\"\n  cronjob  | sudo dd of=\"$cronjob\"\n  header   | sudo dd of=/etc/haproxy/\"$conf_file\"\n}\n\nfunction cronjob {\ncat <<EOF\n* * * * * root $script_path logged refresh_system_haproxy \\$(cat $cronjob_conf_file)\nEOF\n}\n\nfunction config {\n  header\n  apps \"$@\"\n}\n\nfunction header {\ncat <<\\EOF\nglobal\n  daemon\n  log 127.0.0.1 local0\n  log 127.0.0.1 local1 notice\n  maxconn 4096\n\ndefaults\n  log            global\n  retries             3\n  maxconn          2000\n  timeout connect  5000\n  timeout client  50000\n  timeout server  50000\n\nlisten stats\n  bind 127.0.0.1:9090\n  balance\n  mode http\n  stats enable\n  stats auth admin:admin\nEOF\n}\n\nfunction apps {\n  (until curl -sSfLk -m 10 -H 'Accept: text/plain' \"${1%/}\"/v2/tasks; do [ $# -lt 2 ] && return 1 || shift; done) | while read -r txt\n  do\n    set -- $txt\n    if [ $# -lt 2 ]; then\n      shift $#\n      continue\n    fi\n\n    local app_name=\"$1\"\n    local app_port=\"$2\"\n    shift 2\n\n    if [ ! -z \"${app_port##*[!0-9]*}\" ]\n    then\n      cat <<EOF\n\nlisten $app_name-$app_port\n  bind 0.0.0.0:$app_port\n  mode tcp\n  option tcplog\n  balance leastconn\nEOF\n      while [[ $# -ne 0 ]]\n      do\n        out \"  server ${app_name}-$# $1 check\"\n        shift\n      done\n    fi\n  done\n}\n\nfunction logged {\n  exec 1> >(logger -p user.info -t \"$name[$$]\")\n  exec 2> >(logger -p user.notice -t \"$name[$$]\")\n  \"$@\"\n}\n\nfunction msg { out \"$*\" >&2 ;}\nfunction err { local x=$? ; msg \"$*\" ; return $(( $x == 0 ? 1 : $x )) ;}\nfunction out { printf '%s\\n' \"$*\" ;}\n\n# If less than 1 argument is provided, print usage and exit. At least one\n# argument is required as described in the `USAGE` message.\n[ $# -lt 1 ] && { -h; exit 1; }\n\nif [[ ${1:-} ]] && declare -F | cut -d' ' -f3 | fgrep -qx -- \"${1:-}\"\nthen \"$@\"\nelse main \"$@\"\nfi",
              "path": "/usr/local/bin/haproxy-marathon-bridge",
              "mode": "755"
            },
            "id": "state-7AD6D28B-0230-4DC5-8164-536C9CF31A97",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "master1:8080\nmaster2:8080\nmaster3:8080",
              "path": "/etc/haproxy-marathon-bridge/marathons"
            },
            "id": "state-7BA7B0BC-3001-419D-9399-71803A78FC5B",
            "module": "linux.file"
          }, {
            "parameter": {
              "if-path-absent": ["/etc/haproxy-marathon-bridge/setup"],
              "cmd": "/usr/local/bin/haproxy-marathon-bridge install_cronjob && touch /etc/haproxy-marathon-bridge/setup"
            },
            "id": "state-5BC75ABA-B3B1-436A-BE0B-1C0863EAE035",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "name": [{
                "key": "haproxy",
                "value": ""
              }]
            },
            "id": "state-1827DC17-5623-447C-A087-A6819D82BBE6",
            "module": "linux.service"
          }, {
            "parameter": {
              "comment": "---- mesos slave ----"
            },
            "id": "state-198F4047-74B0-47A2-9B50-DA7CDB1D74C1",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "zk://@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2181,@{2286840C-58C1-4A0A-B592-20B62381D448.PrivateIpAddress}:2181,@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress}:2181/mesos",
              "path": "/etc/mesos/zk"
            },
            "id": "state-8A5CB16A-F824-40C7-8104-F4CDDA1594CE",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/mesos-slave/ip"
            },
            "id": "state-C769F3A2-281F-4F0A-9DC8-CC87426769C1",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/mesos-slave/hostname"
            },
            "id": "state-5B7C5B2D-52B7-496B-B6FA-D13707807E27",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "docker,mesos",
              "path": "/etc/mesos-slave/containerizers"
            },
            "id": "state-35C2659E-702A-44C4-AD75-6C45663738E1",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "5mins",
              "path": "/etc/mesos-slave/executor_registration_timeout"
            },
            "id": "state-65F8556D-8237-4C4B-B4BA-5E99E3E1AD5D",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "subnet:web;public:true;rack=rack-5;asg:asg0;zone:all",
              "path": "/etc/mesos-slave/attributes"
            },
            "id": "state-4D438325-7028-4B69-85DA-07CD977E7891",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- service ----"
            },
            "id": "state-906792F4-0688-4ADD-BB01-0BE4BFEF8349",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "#!/bin/sh\n### BEGIN INIT INFO\n# Provides:          mesos-slave\n# Required-Start:    $local_fs $remote_fs $network $syslog\n# Required-Stop:     $local_fs $remote_fs $network $syslog\n# Should-Start:      docker\n# Should-Stop:       docker\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: starts the mesos slave\n# Description:       The Mesos master slave performs computing tasks\n### END INIT INFO\nset -ue\n\nNAME=\"mesos-slave\"\nDESC=\"mesos slave\"\n\n. /lib/lsb/init-functions\n\nPID=/var/run/mesos-slave.pid\n\nstart() {\n  start-stop-daemon --start --background --quiet \\\n                    --pidfile \"$PID\" --make-pidfile \\\n                    --startas /usr/bin/mesos-init-wrapper -- slave\n}\n\nstop() {\n  start-stop-daemon --stop --quiet --pidfile \"$PID\"\n}\n\ncase \"$1\" in\n  start)\n    echo -n \"Starting $DESC: \"\n    start\n    echo \"$NAME.\"\n    ;;\n  stop)\n    echo -n \"Stopping $DESC: \"\n    stop\n    echo \"$NAME.\"\n    ;;\n  restart)\n    echo -n \"Restarting $DESC: \"\n    stop\n    sleep 1\n    start\n    echo \"$NAME.\"\n    ;;\n  status)\n    status_of_proc -p \"$PID\" \"$NAME\" \"$NAME\"\n    ;;\n  *)\n    echo \"Usage: $0 {start|stop|restart|status}\" >&2\n    exit 1\n    ;;\nesac",
              "path": "/etc/init.d/mesos-slave",
              "mode": "755"
            },
            "id": "state-28EC4105-F13D-4DCB-9C3C-EFD9EA77EB16",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "manual",
              "path": "/etc/init/mesos-master.override"
            },
            "id": "state-6205D358-3736-4514-8DBA-E1892D4EC469",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "manual",
              "path": "/etc/init/zookeeper.override"
            },
            "id": "state-339CBDC6-009D-4DAD-B75C-4D551362012F",
            "module": "linux.file"
          }, {
            "parameter": {
              "watch": ["/etc/mesos/zk", "/etc/mesos-slave/ip", "/etc/mesos-slave/hostname", "/etc/mesos-slave/containerizers", "/etc/mesos-slave/executor_registration_timeout", "/etc/mesos-slave/attributes"],
              "name": [{
                "key": "mesos-slave",
                "value": ""
              }]
            },
            "id": "state-9554E8F5-FBB9-4040-B570-A54799DF3E47",
            "module": "linux.service"
          }],
          "resource": {
            "UserData": "",
            "LaunchConfigurationARN": "",
            "InstanceMonitoring": false,
            "ImageId": imageId,
            "KeyName": "@{9A09C5A2-4D66-4E2E-91AB-4F3F4E129F3E.resource.KeyName}",
            "EbsOptimized": false,
            "BlockDeviceMapping": [{
              "DeviceName": "/dev/sda1",
              "Ebs": {
                "SnapshotId": "snap-00fc3bbc",
                "VolumeSize": 8,
                "VolumeType": "gp2"
              }
            }],
            "SecurityGroups": ["@{AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8.resource.GroupId}", "@{62A273C5-19E8-4635-8622-511E121A7340.resource.GroupId}", "@{3D3060F5-CFF8-458D-B081-C424C3063854.resource.GroupId}", "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}"],
            "LaunchConfigurationName": "launch-config-0",
            "InstanceType": "t2.micro",
            "AssociatePublicIpAddress": true
          }
        },
        "62A273C5-19E8-4635-8622-511E121A7340": {
          "name": "pub-sg",
          "type": "AWS.EC2.SecurityGroup",
          "uid": "62A273C5-19E8-4635-8622-511E121A7340",
          "resource": {
            "Default": false,
            "GroupId": "",
            "GroupName": "pub-sg",
            "GroupDescription": "Custom Security Group",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "IpPermissions": [{
              "FromPort": "80",
              "ToPort": "80",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "443",
              "ToPort": "443",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }],
            "IpPermissionsEgress": [],
            "Tags": [{
              "Key": "visops_default",
              "Value": "false"
            }]
          }
        },
        "65084675-8D1A-49E0-A018-DC02479857FE": {
          "uid": "65084675-8D1A-49E0-A018-DC02479857FE",
          "name": "#{regionName}b",
          "type": "AWS.EC2.AvailabilityZone",
          "resource": {
            "ZoneName": "#{regionName}b",
            "RegionName": "#{regionName}"
          }
        },
        "9A09C5A2-4D66-4E2E-91AB-4F3F4E129F3E": {
          "name": "DefaultKP",
          "type": "AWS.EC2.KeyPair",
          "uid": "9A09C5A2-4D66-4E2E-91AB-4F3F4E129F3E",
          "resource": {
            "KeyFingerprint": "",
            "KeyName": "DefaultKP"
          }
        },
        "AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8": {
          "name": "DefaultSG",
          "type": "AWS.EC2.SecurityGroup",
          "uid": "AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8",
          "resource": {
            "Default": true,
            "GroupId": "",
            "GroupName": "DefaultSG",
            "GroupDescription": "default VPC security group",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "IpPermissions": [{
              "FromPort": "22",
              "ToPort": "22",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }],
            "IpPermissionsEgress": [{
              "FromPort": "0",
              "ToPort": "65535",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "-1"
            }],
            "Tags": [{
              "Key": "visops_default",
              "Value": "true"
            }]
          }
        },
        "3D3060F5-CFF8-458D-B081-C424C3063854": {
          "name": "mesos-slave",
          "type": "AWS.EC2.SecurityGroup",
          "uid": "3D3060F5-CFF8-458D-B081-C424C3063854",
          "resource": {
            "Default": false,
            "GroupId": "",
            "GroupName": "mesos-slave",
            "GroupDescription": "Custom Security Group",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "IpPermissions": [{
              "FromPort": "0",
              "ToPort": "65535",
              "IpRanges": "@{3D3060F5-CFF8-458D-B081-C424C3063854.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "31000",
              "ToPort": "32000",
              "IpRanges": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "5051",
              "ToPort": "5051",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }],
            "IpPermissionsEgress": [{
              "FromPort": "0",
              "ToPort": "65535",
              "IpRanges": "@{3D3060F5-CFF8-458D-B081-C424C3063854.resource.GroupId}",
              "IpProtocol": "tcp"
            }],
            "Tags": [{
              "Key": "visops_default",
              "Value": "false"
            }]
          }
        },
        "831F4E97-2B70-4947-803C-AB64AE840C2E": {
          "name": "mesos-base",
          "type": "AWS.EC2.SecurityGroup",
          "uid": "831F4E97-2B70-4947-803C-AB64AE840C2E",
          "resource": {
            "Default": false,
            "GroupId": "",
            "GroupName": "mesos-base",
            "GroupDescription": "Custom Security Group",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "IpPermissions": [],
            "IpPermissionsEgress": [{
              "FromPort": "5050",
              "ToPort": "5050",
              "IpRanges": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "8080",
              "ToPort": "8080",
              "IpRanges": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "2181",
              "ToPort": "2181",
              "IpRanges": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "5051",
              "ToPort": "5051",
              "IpRanges": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "31000",
              "ToPort": "32000",
              "IpRanges": "@{3D3060F5-CFF8-458D-B081-C424C3063854.resource.GroupId}",
              "IpProtocol": "tcp"
            }],
            "Tags": [{
              "Key": "visops_default",
              "Value": "false"
            }]
          }
        },
        "445C1E2B-4DFD-4388-8BB7-79ED1DE9745C": {
          "name": "mesos-master",
          "type": "AWS.EC2.SecurityGroup",
          "uid": "445C1E2B-4DFD-4388-8BB7-79ED1DE9745C",
          "resource": {
            "Default": false,
            "GroupId": "",
            "GroupName": "mesos-master",
            "GroupDescription": "Mesos/Marathon master and Zookeeper",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "IpPermissions": [{
              "FromPort": "5050",
              "ToPort": "5050",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "8080",
              "ToPort": "8080",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "2888",
              "ToPort": "3888",
              "IpRanges": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "5050",
              "ToPort": "5050",
              "IpRanges": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "8080",
              "ToPort": "8080",
              "IpRanges": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "2181",
              "ToPort": "2181",
              "IpRanges": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "5051",
              "ToPort": "5051",
              "IpRanges": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}",
              "IpProtocol": "tcp"
            }],
            "IpPermissionsEgress": [{
              "FromPort": "2888",
              "ToPort": "3888",
              "IpRanges": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}",
              "IpProtocol": "tcp"
            }],
            "Tags": [{
              "Key": "visops_default",
              "Value": "false"
            }]
          }
        },
        "6CEF96E2-E2F0-42E5-8601-02E6DDE5C577": {
          "uid": "6CEF96E2-E2F0-42E5-8601-02E6DDE5C577",
          "name": "#{regionName}a",
          "type": "AWS.EC2.AvailabilityZone",
          "resource": {
            "ZoneName": "#{regionName}a",
            "RegionName": "#{regionName}"
          }
        },
        "FABDEDD1-E3D6-4B58-9963-680A2DD52A72": {
          "name": "web-a",
          "description": "",
          "type": "AWS.VPC.Subnet",
          "uid": "FABDEDD1-E3D6-4B58-9963-680A2DD52A72",
          "resource": {
            "AvailabilityZone": "@{6CEF96E2-E2F0-42E5-8601-02E6DDE5C577.resource.ZoneName}",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "",
            "CidrBlock": "10.0.0.0/24"
          }
        },
        "BA041E65-6720-4FD2-AD73-993DC0DF6C79": {
          "name": "web-b",
          "description": "",
          "type": "AWS.VPC.Subnet",
          "uid": "BA041E65-6720-4FD2-AD73-993DC0DF6C79",
          "resource": {
            "AvailabilityZone": "@{65084675-8D1A-49E0-A018-DC02479857FE.resource.ZoneName}",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "",
            "CidrBlock": "10.0.1.0/24"
          }
        },
        "6BE3D1A2-1233-4A86-AC11-B944B9E34CBF": {
          "name": "sched-a",
          "description": "",
          "type": "AWS.VPC.Subnet",
          "uid": "6BE3D1A2-1233-4A86-AC11-B944B9E34CBF",
          "resource": {
            "AvailabilityZone": "@{6CEF96E2-E2F0-42E5-8601-02E6DDE5C577.resource.ZoneName}",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "",
            "CidrBlock": "10.0.2.0/24"
          }
        },
        "827F9D8A-F900-44C8-833E-D20628BF8DF5": {
          "name": "sched-b",
          "description": "",
          "type": "AWS.VPC.Subnet",
          "uid": "827F9D8A-F900-44C8-833E-D20628BF8DF5",
          "resource": {
            "AvailabilityZone": "@{65084675-8D1A-49E0-A018-DC02479857FE.resource.ZoneName}",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "",
            "CidrBlock": "10.0.3.0/24"
          }
        },
        "2286840C-58C1-4A0A-B592-20B62381D448": {
          "type": "AWS.EC2.Instance",
          "uid": "2286840C-58C1-4A0A-B592-20B62381D448",
          "name": "master-1",
          "description": "",
          "index": 0,
          "number": 1,
          "serverGroupUid": "2286840C-58C1-4A0A-B592-20B62381D448",
          "serverGroupName": "master-1",
          "state": [{
            "parameter": {
              "comment": "---- pkg ----"
            },
            "id": "state-8AE1D307-EED8-4C7D-B002-977294728399",
            "module": "meta.comment"
          }, {
            "parameter": {
              "cmd": "apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF"
            },
            "id": "state-27DE6148-219C-4535-A7CC-D245C7BA99D0",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "content": "deb http://repos.mesosphere.io/ubuntu trusty main",
              "name": "mesos"
            },
            "id": "state-4300A1F5-90DA-4490-B3B8-900CC87274D8",
            "module": "linux.apt.repo"
          }, {
            "parameter": {
              "name": [{
                "key": "mesosphere",
                "value": ""
              }, {
                "key": "openjdk-7-jre-headless",
                "value": ""
              }]
            },
            "id": "state-16132617-57A3-4866-9AB9-AEF9DC872B36",
            "module": "linux.apt.package"
          }, {
            "parameter": {
              "cmd": "[ -f /var/lib/zookeeper/myid ] && [ $(echo /var/lib/zookeeper/myid | wc -c) -gt 3 ] && initctl stop zookeeper"
            },
            "id": "state-BFAE7717-339B-41DE-9FC9-834F4A38CF40",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "comment": "---- zookeeper ----"
            },
            "id": "state-449C88EF-CE34-420E-A3D1-F7DB6E5A0649",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "2",
              "path": "/var/lib/zookeeper/myid"
            },
            "id": "state-F768797A-227B-42B4-8F10-D62558B36971",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "tickTime=2000\ninitLimit=10\nsyncLimit=5\ndataDir=/var/lib/zookeeper\nclientPort=2181\nserver.1=@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2888:3888\nserver.2=@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2888:3888\nserver.3=@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress}:2888:3888",
              "path": "/etc/zookeeper/conf/zoo.cfg"
            },
            "id": "state-AA502CCE-FE44-46DA-AE1D-6C7BF52D1067",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- mesos master ----"
            },
            "id": "state-3BE88C28-4283-4E93-8864-6889205173F9",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "zk://@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2181,@{2286840C-58C1-4A0A-B592-20B62381D448.PrivateIpAddress}:2181,@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress}:2181/mesos",
              "path": "/etc/mesos/zk"
            },
            "id": "state-3D9B852A-D035-454B-93F5-1D49C3DCF40A",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "2",
              "path": "/etc/mesos-master/quorum"
            },
            "id": "state-C4CABD74-5482-4AD4-ACC0-8A7AAF428AAE",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/mesos-master/ip"
            },
            "id": "state-A4648C33-5732-4D07-AE8A-A29C7E57D04D",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/mesos-master/hostname"
            },
            "id": "state-A27D3C87-1430-4144-96F4-B4B4FB2CD568",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "Mesos Cluster",
              "path": "/etc/mesos-master/cluster"
            },
            "id": "state-1437287B-D1AB-49C7-BAAA-E71D370D297C",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- marathon ----"
            },
            "id": "state-89B37D75-F9D3-48A6-98CD-C6F0BC24AB89",
            "module": "meta.comment"
          }, {
            "parameter": {
              "path": ["/etc/marathon/conf"],
              "recursive": true
            },
            "id": "state-CCFBFFDD-B91B-43E1-B5D4-4F4B2DA278F0",
            "module": "linux.dir"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/marathon/conf/hostname"
            },
            "id": "state-0875885B-4C46-49E2-9EC8-0E0DABE1CF2E",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "zk://master1:2181,master2:2181,master3:2181/mesos",
              "path": "/etc/marathon/conf/master"
            },
            "id": "state-485F2888-1AF6-4870-8CF7-2A12AB2840E6",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "zk://master1:2181,master2:2181,master3:2181/marathon",
              "path": "/etc/marathon/conf/zk"
            },
            "id": "state-2C4F3908-9370-44FA-86CC-3B4019D1DAA0",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- service ----"
            },
            "id": "state-47C3DC07-84A8-4AA8-8520-33E665943583",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "127.0.0.1 localhost\n\n@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress} master1\n@{2286840C-58C1-4A0A-B592-20B62381D448.PrivateIpAddress} master2\n@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress} master3\n\n# The following lines are desirable for IPv6 capable hosts\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\nff02::3 ip6-allhosts\n",
              "path": "/etc/hosts"
            },
            "id": "state-0D305423-C66B-4696-89C0-34BF97F9C630",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "master2",
              "path": "/etc/hostname"
            },
            "id": "state-4C32C390-C49C-413E-A770-6E04FB5D05FC",
            "module": "linux.file"
          }, {
            "parameter": {
              "cmd": "hostname $(cat /etc/hostname)"
            },
            "id": "state-A9635EB6-8E00-446B-A0D4-6EBFBD70245A",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "content": "description \"mesos master\"\n\n# Start just after the System-V jobs (rc) to ensure networking and zookeeper\n# are started. This is as simple as possible to ensure compatibility with\n# Ubuntu, Debian, CentOS, and RHEL distros. See:\n# http://upstart.ubuntu.com/cookbook/#standard-idioms\nstart on RUNLEVEL=[2345]\nrespawn\n\nexec /usr/bin/mesos-init-wrapper master",
              "path": "/etc/init/mesos-master.conf"
            },
            "id": "state-1E7952B6-2CF2-466D-A3B2-4F2017C13803",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "#!/bin/bash\n### BEGIN INIT INFO\n# Provides:          mesos-master\n# Required-Start:    $local_fs $remote_fs $network $syslog\n# Required-Stop:     $local_fs $remote_fs $network $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: starts the mesos master\n# Description:       The Mesos master distributes computing tasks to slaves\n### END INIT INFO\nset -ue\n\nNAME=\"mesos-master\"\nDESC=\"mesos master\"\n\n. /lib/lsb/init-functions\n\nPID=/var/run/mesos-master.pid\n\nstart() {\n  start-stop-daemon --start --background --quiet \\\n                    --pidfile \"$PID\" --make-pidfile \\\n                    --startas /usr/bin/mesos-init-wrapper -- master\n}\n\nstop() {\n  start-stop-daemon --stop --quiet --pidfile \"$PID\"\n}\n\ncase \"$1\" in\n  start)\n    echo -n \"Starting $DESC: \"\n    start\n    echo \"$NAME.\"\n    ;;\n  stop)\n    echo -n \"Stopping $DESC: \"\n    stop\n    echo \"$NAME.\"\n    ;;\n  restart)\n    echo -n \"Restarting $DESC: \"\n    stop\n    sleep 1\n    start\n    echo \"$NAME.\"\n    ;;\n  status)\n    status_of_proc -p \"$PID\" \"$NAME\" \"$NAME\"\n    ;;\n  *)\n    echo \"Usage: $0 {start|stop|restart|status}\" >&2\n    exit 1\n    ;;\nesac\n",
              "path": "/etc/init.d/mesos-master",
              "mode": "755"
            },
            "id": "state-B5C83AE4-CD20-4540-BE0D-E9B05240B5B7",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "manual",
              "path": "/etc/init/mesos-slave.override"
            },
            "id": "state-072E73DF-C049-4E1D-A705-F210AAE5FB24",
            "module": "linux.file"
          }, {
            "parameter": {
              "watch": ["/var/lib/zookeeper/myid", "/etc/zookeeper/conf/zoo.cfg"],
              "name": [{
                "key": "zookeeper",
                "value": ""
              }]
            },
            "id": "state-03888681-2480-4CDB-9BE5-D7470CB25FDE",
            "module": "linux.service"
          }, {
            "parameter": {
              "watch": ["/etc/mesos/zk", "/etc/mesos-master/quorum", "/etc/mesos-master/ip", "/etc/mesos-master/hostname", "/etc/mesos-master/cluster"],
              "name": [{
                "key": "mesos-master",
                "value": ""
              }]
            },
            "id": "state-339B6CF5-0D33-4797-80F9-CCA71856104E",
            "module": "linux.service"
          }, {
            "parameter": {
              "watch": ["/etc/marathon/conf/hostname", "/etc/marathon/conf/master", "/etc/marathon/conf/zk"],
              "name": [{
                "key": "marathon",
                "value": ""
              }]
            },
            "id": "state-1E0CAA26-09A9-463D-910C-4F714E5A355B",
            "module": "linux.service"
          }],
          "resource": {
            "UserData": {
              "Base64Encoded": false,
              "Data": ""
            },
            "BlockDeviceMapping": [{
              "DeviceName": "/dev/sda1",
              "Ebs": {
                "SnapshotId": "snap-00fc3bbc",
                "VolumeSize": 8,
                "VolumeType": "gp2"
              }
            }],
            "Placement": {
              "Tenancy": "",
              "AvailabilityZone": "@{6CEF96E2-E2F0-42E5-8601-02E6DDE5C577.resource.ZoneName}"
            },
            "InstanceId": "",
            "ImageId": imageId,
            "KeyName": "@{9A09C5A2-4D66-4E2E-91AB-4F3F4E129F3E.resource.KeyName}",
            "EbsOptimized": false,
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "@{6BE3D1A2-1233-4A86-AC11-B944B9E34CBF.resource.SubnetId}",
            "Monitoring": "disabled",
            "NetworkInterface": [],
            "InstanceType": "t2.micro",
            "DisableApiTermination": false,
            "ShutdownBehavior": "terminate",
            "SecurityGroup": [],
            "SecurityGroupId": []
          }
        },
        "D0CE2EA5-E57A-4778-A0EA-BC3F76DC85F5": {
          "index": 0,
          "uid": "D0CE2EA5-E57A-4778-A0EA-BC3F76DC85F5",
          "type": "AWS.VPC.NetworkInterface",
          "name": "master-1-eni0",
          "serverGroupUid": "D0CE2EA5-E57A-4778-A0EA-BC3F76DC85F5",
          "serverGroupName": "eni0",
          "number": 1,
          "resource": {
            "SourceDestCheck": true,
            "Description": "",
            "NetworkInterfaceId": "",
            "AvailabilityZone": "@{6CEF96E2-E2F0-42E5-8601-02E6DDE5C577.resource.ZoneName}",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "@{6BE3D1A2-1233-4A86-AC11-B944B9E34CBF.resource.SubnetId}",
            "AssociatePublicIpAddress": true,
            "PrivateIpAddressSet": [{
              "PrivateIpAddress": "10.0.2.5",
              "AutoAssign": true,
              "Primary": true
            }],
            "GroupSet": [{
              "GroupName": "@{AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8.resource.GroupName}",
              "GroupId": "@{AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8.resource.GroupId}"
            }, {
              "GroupName": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupName}",
              "GroupId": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}"
            }, {
              "GroupName": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupName}",
              "GroupId": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}"
            }],
            "Attachment": {
              "InstanceId": "@{2286840C-58C1-4A0A-B592-20B62381D448.resource.InstanceId}",
              "DeviceIndex": "0",
              "AttachmentId": ""
            }
          }
        },
        "60616F45-DEE6-4567-95E4-2DE1F23C9CD0": {
          "uid": "60616F45-DEE6-4567-95E4-2DE1F23C9CD0",
          "name": "slave-asg-0",
          "description": "",
          "type": "AWS.AutoScaling.Group",
          "resource": {
            "AvailabilityZones": ["@{6CEF96E2-E2F0-42E5-8601-02E6DDE5C577.resource.ZoneName}", "@{65084675-8D1A-49E0-A018-DC02479857FE.resource.ZoneName}"],
            "VPCZoneIdentifier": "@{FABDEDD1-E3D6-4B58-9963-680A2DD52A72.resource.SubnetId} , @{BA041E65-6720-4FD2-AD73-993DC0DF6C79.resource.SubnetId}",
            "LoadBalancerNames": [],
            "AutoScalingGroupARN": "",
            "DefaultCooldown": "300",
            "MinSize": "1",
            "MaxSize": "2",
            "HealthCheckType": "EC2",
            "HealthCheckGracePeriod": "300",
            "TerminationPolicies": ["Default"],
            "AutoScalingGroupName": "asg0",
            "DesiredCapacity": "1",
            "LaunchConfigurationName": "@{47C1B56E-E96C-418B-8F38-5BCEEE95BC18.resource.LaunchConfigurationName}"
          }
        },
        "5B284722-5E1B-4E76-852C-D71135A7D276": {
          "type": "AWS.EC2.Instance",
          "uid": "5B284722-5E1B-4E76-852C-D71135A7D276",
          "name": "master-0",
          "description": "",
          "index": 0,
          "number": 1,
          "serverGroupUid": "5B284722-5E1B-4E76-852C-D71135A7D276",
          "serverGroupName": "master-0",
          "state": [{
            "parameter": {
              "comment": "---- pkg ----"
            },
            "id": "state-D3930CF4-9CB4-4EBE-9285-C3D8D250FC5B",
            "module": "meta.comment"
          }, {
            "parameter": {
              "cmd": "apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF"
            },
            "id": "state-20C98D42-4691-446A-84E6-8E6CD7113368",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "content": "deb http://repos.mesosphere.io/ubuntu trusty main",
              "name": "mesos"
            },
            "id": "state-0DCFBB61-412A-4BA4-BAF8-4682CD807DA8",
            "module": "linux.apt.repo"
          }, {
            "parameter": {
              "name": [{
                "key": "mesosphere",
                "value": ""
              }, {
                "key": "openjdk-7-jre-headless",
                "value": ""
              }]
            },
            "id": "state-0403D1C1-9544-4922-912E-301DCE843A1A",
            "module": "linux.apt.package"
          }, {
            "parameter": {
              "cmd": "[ -f /var/lib/zookeeper/myid ] && [ $(echo /var/lib/zookeeper/myid | wc -c) -gt 3 ] && initctl stop zookeeper"
            },
            "id": "state-A14656B7-0E37-4BF7-A805-802C9C8B5CBA",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "comment": "---- zookeeper ----"
            },
            "id": "state-1BCEF87A-2348-4D40-AD0B-7DD3FD48FEAC",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "1",
              "path": "/var/lib/zookeeper/myid"
            },
            "id": "state-D348E2F7-C6D1-4B70-B1A3-002788BA7DB9",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "tickTime=2000\ninitLimit=10\nsyncLimit=5\ndataDir=/var/lib/zookeeper\nclientPort=2181\nserver.1=@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2888:3888\nserver.2=@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2888:3888\nserver.3=@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress}:2888:3888",
              "path": "/etc/zookeeper/conf/zoo.cfg"
            },
            "id": "state-58E114EE-9DEF-41B6-AA34-7F5D9DC79853",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- mesos master ----"
            },
            "id": "state-944112CA-9BAB-4973-8DC7-BA0A3CA4D966",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "zk://@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2181,@{2286840C-58C1-4A0A-B592-20B62381D448.PrivateIpAddress}:2181,@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress}:2181/mesos",
              "path": "/etc/mesos/zk"
            },
            "id": "state-B507A877-B56A-4E4B-96F8-7ED6A5428514",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "2",
              "path": "/etc/mesos-master/quorum"
            },
            "id": "state-12494AEC-8115-4C8B-9F53-6FE1FACFB600",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/mesos-master/ip"
            },
            "id": "state-692D0FA1-1AAE-408A-AAEF-046935D47FF3",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/mesos-master/hostname"
            },
            "id": "state-7E456427-3C11-4B1A-BF7E-B1C35DC21361",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "Mesos Cluster",
              "path": "/etc/mesos-master/cluster"
            },
            "id": "state-265FDBE4-8EE1-48E0-838E-FAAEC4CA2C74",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- marathon ----"
            },
            "id": "state-6CF8EC0F-8555-4F2B-97BA-657CB154BE37",
            "module": "meta.comment"
          }, {
            "parameter": {
              "path": ["/etc/marathon/conf"],
              "recursive": true
            },
            "id": "state-45D49F15-8CAA-4DD2-A3B0-2060992CA836",
            "module": "linux.dir"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/marathon/conf/hostname"
            },
            "id": "state-15BA04FC-1F2F-4B3F-B445-B9DAC92E2A57",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "zk://master1:2181,master2:2181,master3:2181/mesos",
              "path": "/etc/marathon/conf/master"
            },
            "id": "state-BDC2F57F-E181-4950-AAC2-80A108D8EC03",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "zk://master1:2181,master2:2181,master3:2181/marathon",
              "path": "/etc/marathon/conf/zk"
            },
            "id": "state-1EE9FBE9-9C9A-47CA-B46E-6CBE7F57FFC9",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- service ----"
            },
            "id": "state-D22550E2-7D0F-441D-BDBF-AB3CB79C18AB",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "127.0.0.1 localhost\n\n@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress} master1\n@{2286840C-58C1-4A0A-B592-20B62381D448.PrivateIpAddress} master2\n@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress} master3\n\n# The following lines are desirable for IPv6 capable hosts\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\nff02::3 ip6-allhosts\n",
              "path": "/etc/hosts"
            },
            "id": "state-4A2A2A0B-81FD-41DF-8242-5749B66DE673",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "master1",
              "path": "/etc/hostname"
            },
            "id": "state-C7B0B3F9-D7B0-4573-B791-3A36394E0172",
            "module": "linux.file"
          }, {
            "parameter": {
              "cmd": "hostname $(cat /etc/hostname)"
            },
            "id": "state-DF137453-0C48-4040-B666-62C96B08CB6A",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "content": "description \"mesos master\"\n\n# Start just after the System-V jobs (rc) to ensure networking and zookeeper\n# are started. This is as simple as possible to ensure compatibility with\n# Ubuntu, Debian, CentOS, and RHEL distros. See:\n# http://upstart.ubuntu.com/cookbook/#standard-idioms\nstart on RUNLEVEL=[2345]\nrespawn\n\nexec /usr/bin/mesos-init-wrapper master",
              "path": "/etc/init/mesos-master.conf"
            },
            "id": "state-07AD9DA7-4461-49BB-B275-DD701FAE5C67",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "#!/bin/bash\n### BEGIN INIT INFO\n# Provides:          mesos-master\n# Required-Start:    $local_fs $remote_fs $network $syslog\n# Required-Stop:     $local_fs $remote_fs $network $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: starts the mesos master\n# Description:       The Mesos master distributes computing tasks to slaves\n### END INIT INFO\nset -ue\n\nNAME=\"mesos-master\"\nDESC=\"mesos master\"\n\n. /lib/lsb/init-functions\n\nPID=/var/run/mesos-master.pid\n\nstart() {\n  start-stop-daemon --start --background --quiet \\\n                    --pidfile \"$PID\" --make-pidfile \\\n                    --startas /usr/bin/mesos-init-wrapper -- master\n}\n\nstop() {\n  start-stop-daemon --stop --quiet --pidfile \"$PID\"\n}\n\ncase \"$1\" in\n  start)\n    echo -n \"Starting $DESC: \"\n    start\n    echo \"$NAME.\"\n    ;;\n  stop)\n    echo -n \"Stopping $DESC: \"\n    stop\n    echo \"$NAME.\"\n    ;;\n  restart)\n    echo -n \"Restarting $DESC: \"\n    stop\n    sleep 1\n    start\n    echo \"$NAME.\"\n    ;;\n  status)\n    status_of_proc -p \"$PID\" \"$NAME\" \"$NAME\"\n    ;;\n  *)\n    echo \"Usage: $0 {start|stop|restart|status}\" >&2\n    exit 1\n    ;;\nesac\n",
              "path": "/etc/init.d/mesos-master",
              "mode": "755"
            },
            "id": "state-621FBC6C-FE88-4ABA-B9B8-D2EDA5A6F825",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "manual",
              "path": "/etc/init/mesos-slave.override"
            },
            "id": "state-BCE053AB-569B-46DA-8C5B-53C3A443229F",
            "module": "linux.file"
          }, {
            "parameter": {
              "watch": ["/var/lib/zookeeper/myid", "/etc/zookeeper/conf/zoo.cfg"],
              "name": [{
                "key": "zookeeper",
                "value": ""
              }]
            },
            "id": "state-71671BB8-270E-43D0-AFF1-0384D21B248E",
            "module": "linux.service"
          }, {
            "parameter": {
              "watch": ["/etc/mesos/zk", "/etc/mesos-master/quorum", "/etc/mesos-master/ip", "/etc/mesos-master/hostname", "/etc/mesos-master/cluster"],
              "name": [{
                "key": "mesos-master",
                "value": ""
              }]
            },
            "id": "state-5C6B6D82-159B-4468-A790-18D1CF0A1C4E",
            "module": "linux.service"
          }, {
            "parameter": {
              "watch": ["/etc/marathon/conf/hostname", "/etc/marathon/conf/master", "/etc/marathon/conf/zk"],
              "name": [{
                "key": "marathon",
                "value": ""
              }]
            },
            "id": "state-101AD663-0988-4891-9C28-87A594ECD6CA",
            "module": "linux.service"
          }],
          "resource": {
            "UserData": {
              "Base64Encoded": false,
              "Data": ""
            },
            "BlockDeviceMapping": [{
              "DeviceName": "/dev/sda1",
              "Ebs": {
                "SnapshotId": "snap-00fc3bbc",
                "VolumeSize": 8,
                "VolumeType": "gp2"
              }
            }],
            "Placement": {
              "Tenancy": "",
              "AvailabilityZone": "@{6CEF96E2-E2F0-42E5-8601-02E6DDE5C577.resource.ZoneName}"
            },
            "InstanceId": "",
            "ImageId": imageId,
            "KeyName": "@{9A09C5A2-4D66-4E2E-91AB-4F3F4E129F3E.resource.KeyName}",
            "EbsOptimized": false,
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "@{6BE3D1A2-1233-4A86-AC11-B944B9E34CBF.resource.SubnetId}",
            "Monitoring": "disabled",
            "NetworkInterface": [],
            "InstanceType": "t2.micro",
            "DisableApiTermination": false,
            "ShutdownBehavior": "terminate",
            "SecurityGroup": [],
            "SecurityGroupId": []
          }
        },
        "CB5785F7-ECBD-41AA-9F66-308DFA5AEEB1": {
          "index": 0,
          "uid": "CB5785F7-ECBD-41AA-9F66-308DFA5AEEB1",
          "type": "AWS.VPC.NetworkInterface",
          "name": "master-0-eni0",
          "serverGroupUid": "CB5785F7-ECBD-41AA-9F66-308DFA5AEEB1",
          "serverGroupName": "eni0",
          "number": 1,
          "resource": {
            "SourceDestCheck": true,
            "Description": "",
            "NetworkInterfaceId": "",
            "AvailabilityZone": "@{6CEF96E2-E2F0-42E5-8601-02E6DDE5C577.resource.ZoneName}",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "@{6BE3D1A2-1233-4A86-AC11-B944B9E34CBF.resource.SubnetId}",
            "AssociatePublicIpAddress": true,
            "PrivateIpAddressSet": [{
              "PrivateIpAddress": "10.0.2.4",
              "AutoAssign": true,
              "Primary": true
            }],
            "GroupSet": [{
              "GroupName": "@{AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8.resource.GroupName}",
              "GroupId": "@{AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8.resource.GroupId}"
            }, {
              "GroupName": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupName}",
              "GroupId": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}"
            }, {
              "GroupName": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupName}",
              "GroupId": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}"
            }],
            "Attachment": {
              "InstanceId": "@{5B284722-5E1B-4E76-852C-D71135A7D276.resource.InstanceId}",
              "DeviceIndex": "0",
              "AttachmentId": ""
            }
          }
        },
        "EE5A9E75-7423-49B8-9A33-CAC48C84C1EE": {
          "type": "AWS.EC2.Instance",
          "uid": "EE5A9E75-7423-49B8-9A33-CAC48C84C1EE",
          "name": "master-2",
          "description": "",
          "index": 0,
          "number": 1,
          "serverGroupUid": "EE5A9E75-7423-49B8-9A33-CAC48C84C1EE",
          "serverGroupName": "master-2",
          "state": [{
            "parameter": {
              "comment": "---- pkg ----"
            },
            "id": "state-A0AFD901-84C7-40CE-9C00-55E2647838D4",
            "module": "meta.comment"
          }, {
            "parameter": {
              "cmd": "apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF"
            },
            "id": "state-3DE2661C-1FCD-4853-B96A-198AED803E9E",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "content": "deb http://repos.mesosphere.io/ubuntu trusty main",
              "name": "mesos"
            },
            "id": "state-83C4485D-CC8F-4B83-895F-3B7BBCBD4E93",
            "module": "linux.apt.repo"
          }, {
            "parameter": {
              "name": [{
                "key": "mesosphere",
                "value": ""
              }, {
                "key": "openjdk-7-jre-headless",
                "value": ""
              }]
            },
            "id": "state-27142035-CC8D-4512-B79C-210B70ED768B",
            "module": "linux.apt.package"
          }, {
            "parameter": {
              "cmd": "[ -f /var/lib/zookeeper/myid ] && [ $(echo /var/lib/zookeeper/myid | wc -c) -gt 3 ] && initctl stop zookeeper"
            },
            "id": "state-99C9ED5D-9728-435E-A624-C081D63EDB6C",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "comment": "---- zookeeper ----"
            },
            "id": "state-77D73AF4-2C9C-4F7C-B670-3273FF7081EB",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "3",
              "path": "/var/lib/zookeeper/myid"
            },
            "id": "state-60301113-1952-440E-A636-B1FFAB20D2BD",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "tickTime=2000\ninitLimit=10\nsyncLimit=5\ndataDir=/var/lib/zookeeper\nclientPort=2181\nserver.1=@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2888:3888\nserver.2=@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2888:3888\nserver.3=@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress}:2888:3888",
              "path": "/etc/zookeeper/conf/zoo.cfg"
            },
            "id": "state-E75D8CC4-21EF-4538-B534-A708B8C1F293",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- mesos master ----"
            },
            "id": "state-CC707B2B-59DD-42EB-92F5-212911D92CF6",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "zk://@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress}:2181,@{2286840C-58C1-4A0A-B592-20B62381D448.PrivateIpAddress}:2181,@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress}:2181/mesos",
              "path": "/etc/mesos/zk"
            },
            "id": "state-33FEC2D5-930F-410E-B55E-4084319AA28C",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "2",
              "path": "/etc/mesos-master/quorum"
            },
            "id": "state-E69D7557-E9B1-4042-BE33-783F178BEC03",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/mesos-master/ip"
            },
            "id": "state-BDAEE3BE-DE62-455E-B21C-4F9E5E33A34D",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/mesos-master/hostname"
            },
            "id": "state-D5F87EC1-84B0-4EA3-B38B-EB256002E385",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "Mesos Cluster",
              "path": "/etc/mesos-master/cluster"
            },
            "id": "state-8179D5B9-D774-4277-90DE-B38BBE417ADF",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- marathon ----"
            },
            "id": "state-4AD8D40F-441A-48D1-B31F-20E5072F8D97",
            "module": "meta.comment"
          }, {
            "parameter": {
              "path": ["/etc/marathon/conf"],
              "recursive": true
            },
            "id": "state-3C51E805-70D9-40B2-9D70-718C9F1E5A17",
            "module": "linux.dir"
          }, {
            "parameter": {
              "content": "@{self.PrivateIpAddress}",
              "path": "/etc/marathon/conf/hostname"
            },
            "id": "state-9E8E4840-5970-4713-A033-09EE448FAC0A",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "zk://master1:2181,master2:2181,master3:2181/mesos",
              "path": "/etc/marathon/conf/master"
            },
            "id": "state-A9A3FC56-B5EB-4CB8-80B8-2A1104524121",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "zk://master1:2181,master2:2181,master3:2181/marathon",
              "path": "/etc/marathon/conf/zk"
            },
            "id": "state-07B931EC-D5C7-4898-A35F-AC2153AE4A4E",
            "module": "linux.file"
          }, {
            "parameter": {
              "comment": "---- service ----"
            },
            "id": "state-C79C70D3-351C-45A5-B755-200EDB999F84",
            "module": "meta.comment"
          }, {
            "parameter": {
              "content": "127.0.0.1 localhost\n\n@{5B284722-5E1B-4E76-852C-D71135A7D276.PrivateIpAddress} master1\n@{2286840C-58C1-4A0A-B592-20B62381D448.PrivateIpAddress} master2\n@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.PrivateIpAddress} master3\n\n# The following lines are desirable for IPv6 capable hosts\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters\nff02::3 ip6-allhosts\n",
              "path": "/etc/hosts"
            },
            "id": "state-E612EDB9-C80A-453E-9276-95E24B37F93C",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "master3",
              "path": "/etc/hostname"
            },
            "id": "state-171A1D40-4675-4319-A91C-AB1E091006FF",
            "module": "linux.file"
          }, {
            "parameter": {
              "cmd": "hostname $(cat /etc/hostname)"
            },
            "id": "state-5A96227D-6AF9-4535-B81D-61BAD3D6FF54",
            "module": "linux.cmd"
          }, {
            "parameter": {
              "content": "description \"mesos master\"\n\n# Start just after the System-V jobs (rc) to ensure networking and zookeeper\n# are started. This is as simple as possible to ensure compatibility with\n# Ubuntu, Debian, CentOS, and RHEL distros. See:\n# http://upstart.ubuntu.com/cookbook/#standard-idioms\nstart on RUNLEVEL=[2345]\nrespawn\n\nexec /usr/bin/mesos-init-wrapper master\n\n",
              "path": "/etc/init/mesos-master.conf"
            },
            "id": "state-FC3C1650-C760-4C59-9A72-23A43A27430F",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "#!/bin/bash\n### BEGIN INIT INFO\n# Provides:          mesos-master\n# Required-Start:    $local_fs $remote_fs $network $syslog\n# Required-Stop:     $local_fs $remote_fs $network $syslog\n# Default-Start:     2 3 4 5\n# Default-Stop:      0 1 6\n# Short-Description: starts the mesos master\n# Description:       The Mesos master distributes computing tasks to slaves\n### END INIT INFO\nset -ue\n\nNAME=\"mesos-master\"\nDESC=\"mesos master\"\n\n. /lib/lsb/init-functions\n\nPID=/var/run/mesos-master.pid\n\nstart() {\n  start-stop-daemon --start --background --quiet \\\n                    --pidfile \"$PID\" --make-pidfile \\\n                    --startas /usr/bin/mesos-init-wrapper -- master\n}\n\nstop() {\n  start-stop-daemon --stop --quiet --pidfile \"$PID\"\n}\n\ncase \"$1\" in\n  start)\n    echo -n \"Starting $DESC: \"\n    start\n    echo \"$NAME.\"\n    ;;\n  stop)\n    echo -n \"Stopping $DESC: \"\n    stop\n    echo \"$NAME.\"\n    ;;\n  restart)\n    echo -n \"Restarting $DESC: \"\n    stop\n    sleep 1\n    start\n    echo \"$NAME.\"\n    ;;\n  status)\n    status_of_proc -p \"$PID\" \"$NAME\" \"$NAME\"\n    ;;\n  *)\n    echo \"Usage: $0 {start|stop|restart|status}\" >&2\n    exit 1\n    ;;\nesac\n",
              "path": "/etc/init.d/mesos-master",
              "mode": "755"
            },
            "id": "state-5F6ECE1B-AA81-48B3-BD5A-96DD1B13D80A",
            "module": "linux.file"
          }, {
            "parameter": {
              "content": "manual",
              "path": "/etc/init/mesos-slave.override"
            },
            "id": "state-40C628E1-7FA4-4F9D-834B-0DF09B68554E",
            "module": "linux.file"
          }, {
            "parameter": {
              "watch": ["/var/lib/zookeeper/myid", "/etc/zookeeper/conf/zoo.cfg"],
              "name": [{
                "key": "zookeeper",
                "value": ""
              }]
            },
            "id": "state-93CD3149-C117-4C73-B5B7-468A0D0F4EE7",
            "module": "linux.service"
          }, {
            "parameter": {
              "watch": ["/etc/mesos/zk", "/etc/mesos-master/quorum", "/etc/mesos-master/ip", "/etc/mesos-master/hostname", "/etc/mesos-master/cluster"],
              "name": [{
                "key": "mesos-master",
                "value": ""
              }]
            },
            "id": "state-E52B7239-73F9-467C-B89D-229FA5490F17",
            "module": "linux.service"
          }, {
            "parameter": {
              "watch": ["/etc/marathon/conf/hostname", "/etc/marathon/conf/master", "/etc/marathon/conf/zk"],
              "name": [{
                "key": "marathon",
                "value": ""
              }]
            },
            "id": "state-1069BA77-1C19-4785-98ED-B6D3FE7308CA",
            "module": "linux.service"
          }],
          "resource": {
            "UserData": {
              "Base64Encoded": false,
              "Data": ""
            },
            "BlockDeviceMapping": [{
              "DeviceName": "/dev/sda1",
              "Ebs": {
                "SnapshotId": "snap-00fc3bbc",
                "VolumeSize": 8,
                "VolumeType": "gp2"
              }
            }],
            "Placement": {
              "Tenancy": "",
              "AvailabilityZone": "@{65084675-8D1A-49E0-A018-DC02479857FE.resource.ZoneName}"
            },
            "InstanceId": "",
            "ImageId": imageId,
            "KeyName": "@{9A09C5A2-4D66-4E2E-91AB-4F3F4E129F3E.resource.KeyName}",
            "EbsOptimized": false,
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "@{827F9D8A-F900-44C8-833E-D20628BF8DF5.resource.SubnetId}",
            "Monitoring": "disabled",
            "NetworkInterface": [],
            "InstanceType": "t2.micro",
            "DisableApiTermination": false,
            "ShutdownBehavior": "terminate",
            "SecurityGroup": [],
            "SecurityGroupId": []
          }
        },
        "05271095-A8CD-4751-AB2A-AB0DF2561E84": {
          "index": 0,
          "uid": "05271095-A8CD-4751-AB2A-AB0DF2561E84",
          "type": "AWS.VPC.NetworkInterface",
          "name": "master-2-eni0",
          "serverGroupUid": "05271095-A8CD-4751-AB2A-AB0DF2561E84",
          "serverGroupName": "eni0",
          "number": 1,
          "resource": {
            "SourceDestCheck": true,
            "Description": "",
            "NetworkInterfaceId": "",
            "AvailabilityZone": "@{65084675-8D1A-49E0-A018-DC02479857FE.resource.ZoneName}",
            "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}",
            "SubnetId": "@{827F9D8A-F900-44C8-833E-D20628BF8DF5.resource.SubnetId}",
            "AssociatePublicIpAddress": true,
            "PrivateIpAddressSet": [{
              "PrivateIpAddress": "10.0.3.4",
              "AutoAssign": true,
              "Primary": true
            }],
            "GroupSet": [{
              "GroupName": "@{AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8.resource.GroupName}",
              "GroupId": "@{AB8625F1-1CFE-4F14-9880-CE4E20F0ADE8.resource.GroupId}"
            }, {
              "GroupName": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupName}",
              "GroupId": "@{445C1E2B-4DFD-4388-8BB7-79ED1DE9745C.resource.GroupId}"
            }, {
              "GroupName": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupName}",
              "GroupId": "@{831F4E97-2B70-4947-803C-AB64AE840C2E.resource.GroupId}"
            }],
            "Attachment": {
              "InstanceId": "@{EE5A9E75-7423-49B8-9A33-CAC48C84C1EE.resource.InstanceId}",
              "DeviceIndex": "0",
              "AttachmentId": ""
            }
          }
        },
        "99392B0D-12F0-47ED-958F-6E0F9D0B5C28": {
          "name": "Internet-gateway",
          "type": "AWS.VPC.InternetGateway",
          "uid": "99392B0D-12F0-47ED-958F-6E0F9D0B5C28",
          "resource": {
            "InternetGatewayId": "",
            "AttachmentSet": [{
              "VpcId": "@{2D221BC2-A50B-42CA-97CE-CBF5E7C6668E.resource.VpcId}"
            }]
          }
        }
      };
      layout = {
        "520A015A-0902-4E85-8F49-F8F86665C360": {
          "coordinate": [
            76, 8],
          "uid": "520A015A-0902-4E85-8F49-F8F86665C360",
          "groupUId": "2D221BC2-A50B-42CA-97CE-CBF5E7C6668E"
        },
        "2D221BC2-A50B-42CA-97CE-CBF5E7C6668E": {
          "coordinate": [
            8, 7],
          "uid": "2D221BC2-A50B-42CA-97CE-CBF5E7C6668E",
          "size": [
            83, 64]
        },
        "47C1B56E-E96C-418B-8F38-5BCEEE95BC18": {
          "coordinate": [
            0, 0],
          "uid": "47C1B56E-E96C-418B-8F38-5BCEEE95BC18",
          "osType": "ubuntu",
          "architecture": "x86_64",
          "rootDeviceType": "ebs"
        },
        "65084675-8D1A-49E0-A018-DC02479857FE": {
          "coordinate": [
            14, 43],
          "uid": "65084675-8D1A-49E0-A018-DC02479857FE",
          "groupUId": "2D221BC2-A50B-42CA-97CE-CBF5E7C6668E",
          "size": [
            55, 24]
        },
        "6CEF96E2-E2F0-42E5-8601-02E6DDE5C577": {
          "coordinate": [
            14, 14],
          "uid": "6CEF96E2-E2F0-42E5-8601-02E6DDE5C577",
          "groupUId": "2D221BC2-A50B-42CA-97CE-CBF5E7C6668E",
          "size": [
            55, 25]
        },
        "FABDEDD1-E3D6-4B58-9963-680A2DD52A72": {
          "coordinate": [
            47, 17],
          "uid": "FABDEDD1-E3D6-4B58-9963-680A2DD52A72",
          "groupUId": "6CEF96E2-E2F0-42E5-8601-02E6DDE5C577",
          "size": [
            19, 19]
        },
        "BA041E65-6720-4FD2-AD73-993DC0DF6C79": {
          "coordinate": [
            47, 46],
          "uid": "BA041E65-6720-4FD2-AD73-993DC0DF6C79",
          "groupUId": "65084675-8D1A-49E0-A018-DC02479857FE",
          "size": [
            19, 18]
        },
        "6BE3D1A2-1233-4A86-AC11-B944B9E34CBF": {
          "coordinate": [
            17, 17],
          "uid": "6BE3D1A2-1233-4A86-AC11-B944B9E34CBF",
          "groupUId": "6CEF96E2-E2F0-42E5-8601-02E6DDE5C577",
          "size": [
            27, 19]
        },
        "827F9D8A-F900-44C8-833E-D20628BF8DF5": {
          "coordinate": [
            17, 46],
          "uid": "827F9D8A-F900-44C8-833E-D20628BF8DF5",
          "groupUId": "65084675-8D1A-49E0-A018-DC02479857FE",
          "size": [
            28, 18]
        },
        "2286840C-58C1-4A0A-B592-20B62381D448": {
          "coordinate": [
            32, 22],
          "uid": "2286840C-58C1-4A0A-B592-20B62381D448",
          "groupUId": "6BE3D1A2-1233-4A86-AC11-B944B9E34CBF",
          "osType": "ubuntu",
          "architecture": "x86_64",
          "rootDeviceType": "ebs"
        },
        "60616F45-DEE6-4567-95E4-2DE1F23C9CD0": {
          "coordinate": [
            50, 20],
          "uid": "60616F45-DEE6-4567-95E4-2DE1F23C9CD0",
          "groupUId": "FABDEDD1-E3D6-4B58-9963-680A2DD52A72"
        },
        "5B284722-5E1B-4E76-852C-D71135A7D276": {
          "coordinate": [
            20, 22],
          "uid": "5B284722-5E1B-4E76-852C-D71135A7D276",
          "groupUId": "6BE3D1A2-1233-4A86-AC11-B944B9E34CBF",
          "osType": "ubuntu",
          "architecture": "x86_64",
          "rootDeviceType": "ebs"
        },
        "EE5A9E75-7423-49B8-9A33-CAC48C84C1EE": {
          "coordinate": [
            20, 51],
          "uid": "EE5A9E75-7423-49B8-9A33-CAC48C84C1EE",
          "groupUId": "827F9D8A-F900-44C8-833E-D20628BF8DF5",
          "osType": "ubuntu",
          "architecture": "x86_64",
          "rootDeviceType": "ebs"
        },
        "99392B0D-12F0-47ED-958F-6E0F9D0B5C28": {
          "coordinate": [
            4, 8],
          "uid": "99392B0D-12F0-47ED-958F-6E0F9D0B5C28",
          "groupUId": "2D221BC2-A50B-42CA-97CE-CBF5E7C6668E"
        },
        "485EF4EC-BBFE-4E86-B159-8852CDE940F4": {
          "coordinate": [
            50, 49],
          "uid": "485EF4EC-BBFE-4E86-B159-8852CDE940F4",
          "groupUId": "BA041E65-6720-4FD2-AD73-993DC0DF6C79",
          "type": "ExpandedAsg",
          "originalId": "60616F45-DEE6-4567-95E4-2DE1F23C9CD0"
        },
        "size": [
          240, 240]
      }

      json.component = component
      json.layout = layout
      json

  }, {
    supportedProviders : ["aws::global", "aws::china"]
  }

  AwsOpsModel
