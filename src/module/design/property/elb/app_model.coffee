#############################
#  View Mode for design/property/elb
#############################

define [ 'backbone', 'MC' ], () ->

    ElbAppModel = Backbone.Model.extend {

        init : ( elb_uid )->

          myElbComponent = MC.canvas_data.component[ elb_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          elb = $.extend true, {}, appData[ myElbComponent.resource.LoadBalancerName ]
          elb.name = myElbComponent.name

          elb.isInternet = elb.Scheme == "internet-facing"
          elb.HealthCheck.protocol = elb.HealthCheck.Target.split(":")[0]
          elb.HealthCheck.port     = elb.HealthCheck.Target.split(":")[1]

          this.set elb
    }

    new ElbAppModel()
