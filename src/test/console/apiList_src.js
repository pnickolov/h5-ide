var API_DATA_LIST = {

    Forge : {
        Log : {
            put_user_log : {
                method  : '/log:put_user_log',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    user_logs : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            }
        },
        Public : {
            get_hostname : {
                method  : '/public:get_hostname',
                param   : {
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    instance_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            get_dns_ip : {
                method  : '/public:get_dns_ip',
                param   : {
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            }
        },
        Request : {
            init : {
                method  : '/request:init',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            update : {
                method  : '/request:update',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    timestamp : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            }
        },
        Session : {
            login : {
                method  : '/session:login',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    password : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            logout : {
                method  : '/session:logout',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            set_credential : {
                method  : '/session:set_credential',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    access_key : {
                        type   : 'String',
                        value  : 'null'
                    },
                    secret_key : {
                        type   : 'String',
                        value  : 'null'
                    },
                    account_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            guest : {
                method  : '/session:guest',
                param   : {
                    guest_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    guestname : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            }
        },
        App : {
            create : {
                method  : '/app:create',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    spec : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            update : {
                method  : '/app:update',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    spec : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            rename : {
                method  : '/app:rename',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    new_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            terminate : {
                method  : '/app:terminate',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            start : {
                method  : '/app:start',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            stop : {
                method  : '/app:stop',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            reboot : {
                method  : '/app:reboot',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            info : {
                method  : '/app:info',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_ids : {
                        type   : 'Array',
                        value  : 'null'
                    }
                }
            },
            list : {
                method  : '/app:list',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_ids : {
                        type   : 'Array',
                        value  : 'null'
                    }
                }
            },
            resource : {
                method  : '/app:resource',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            summary : {
                method  : '/app:summary',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            }
        },
        Favorite : {
            add : {
                method  : '/favorite:add',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    resource : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            remove : {
                method  : '/favorite:remove',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    resource_ids : {
                        type   : 'Array',
                        value  : 'null'
                    }
                }
            },
            info : {
                method  : '/favorite:info',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    provider : {
                        type   : 'String',
                        value  : 'null'
                    },
                    service : {
                        type   : 'String',
                        value  : 'null'
                    },
                    resource : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            }
        },
        Guest : {
            invite : {
                method  : '/guest:invite',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            cancel : {
                method  : '/guest:cancel',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    guest_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            access : {
                method  : '/guest:access',
                param   : {
                    guestname : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    guest_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            end : {
                method  : '/guest:end',
                param   : {
                    guestname : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    guest_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            info : {
                method  : '/guest:info',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    guest_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            }
        },
        Stack : {
            create : {
                method  : '/stack:create',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    spec : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            remove : {
                method  : '/stack:remove',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            save : {
                method  : '/stack:save',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    spec : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            rename : {
                method  : '/stack:rename',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    new_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            run : {
                method  : '/stack:run',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_desc : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_component : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_property : {
                        type   : 'String',
                        value  : 'null'
                    },
                    app_layout : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            save_as : {
                method  : '/stack:save_as',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    new_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            info : {
                method  : '/stack:info',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_ids : {
                        type   : 'Array',
                        value  : 'null'
                    }
                }
            },
            list : {
                method  : '/stack:list',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    stack_ids : {
                        type   : 'Array',
                        value  : 'null'
                    }
                }
            }
        }
    },

    AWSUtil : {
        AWS : {
            quickstart : {
                method  : '/aws:quickstart',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            public : {
                method  : '/aws:public',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            info : {
                method  : '/aws:info',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            resource : {
                method  : '/aws:resource',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    },
                    region_name : {
                        type   : 'String',
                        value  : 'null'
                    },
                    resources : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            price : {
                method  : '/aws:price',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            },
            status : {
                method  : '/aws:status',
                param   : {
                    username : {
                        type   : 'String',
                        value  : 'null'
                    },
                    session_id : {
                        type   : 'String',
                        value  : 'null'
                    }
                }
            }
        }
    },
	AutoScaling : {
		AutoScaling : {
			DescribeAdjustmentTypes : {
				method : "/aws/autoscaling:DescribeAdjustmentTypes",
				param : {
				}
			},
			DescribeAutoScalingGroups : {
				method : "/aws/autoscaling:DescribeAutoScalingGroups",
				param : {
					group_names : {
						type : "Array",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeAutoScalingInstances : {
				method : "/aws/autoscaling:DescribeAutoScalingInstances",
				param : {
					instance_ids : {
						type : "Array",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeAutoScalingNotificationTypes : {
				method : "/aws/autoscaling:DescribeAutoScalingNotificationTypes",
				param : {
				}
			},
			DescribeLaunchConfigurations : {
				method : "/aws/autoscaling:DescribeLaunchConfigurations",
				param : {
					config_names : {
						type : "Array",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeMetricCollectionTypes : {
				method : "/aws/autoscaling:DescribeMetricCollectionTypes",
				param : {
				}
			},
			DescribeNotificationConfigurations : {
				method : "/aws/autoscaling:DescribeNotificationConfigurations",
				param : {
					group_names : {
						type : "Array",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribePolicies : {
				method : "/aws/autoscaling:DescribePolicies",
				param : {
					group_name : {
						type : "String",
						value : "null"
					},
					policy_names : {
						type : "Array",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeScalingActivities : {
				method : "/aws/autoscaling:DescribeScalingActivities",
				param : {
					group_name : {
						type : "String",
						value : "null"
					},
					activity_ids : {
						type : "Array",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeScalingProcessTypes : {
				method : "/aws/autoscaling:DescribeScalingProcessTypes",
				param : {
				}
			},
			DescribeScheduledActions : {
				method : "/aws/autoscaling:DescribeScheduledActions",
				param : {
					group_name : {
						type : "String",
						value : "null"
					},
					action_names : {
						type : "Array",
						value : "null"
					},
					start_time : {
						type : "Date",
						value : "null"
					},
					end_time : {
						type : "Date",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeTags : {
				method : "/aws/autoscaling:DescribeTags",
				param : {
					filters : {
						type : "Array",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			}
		}
	},
	CloudWatch : {
		CloudWatch : {
			GetMetricStatistics : {
				method : "/aws/cloudwatch:GetMetricStatistics",
				param : {
					metric_name : {
						type : "String",
						value : ""
					},
					namespace : {
						type : "String",
						value : ""
					},
					start_time : {
						type : "Date",
						value : ""
					},
					end_time : {
						type : "Date",
						value : ""
					},
					period : {
						type : "int",
						value : ""
					},
					unit : {
						type : "String",
						value : ""
					},
					statistics : {
						type : "Array",
						value : ""
					},
					dimensions : {
						type : "Array",
						value : "null"
					}
				}
			},
			ListMetrics : {
				method : "/aws/cloudwatch:ListMetrics",
				param : {
					metric_name : {
						type : "String",
						value : "null"
					},
					namespace : {
						type : "String",
						value : "null"
					},
					dimensions : {
						type : "Array",
						value : "null"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeAlarmHistory : {
				method : "/aws/cloudwatch:DescribeAlarmHistory",
				param : {
					alarm_name : {
						type : "String",
						value : "null"
					},
					start_date : {
						type : "Date",
						value : "null"
					},
					end_date : {
						type : "Date",
						value : "null"
					},
					history_item_type : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeAlarms : {
				method : "/aws/cloudwatch:DescribeAlarms",
				param : {
					alarm_names : {
						type : "Array",
						value : "null"
					},
					alarm_name_prefix : {
						type : "String",
						value : "null"
					},
					action_prefix : {
						type : "String",
						value : "null"
					},
					state_value : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeAlarmsForMetric : {
				method : "/aws/cloudwatch:DescribeAlarmsForMetric",
				param : {
					metric_name : {
						type : "String",
						value : ""
					},
					namespace : {
						type : "String",
						value : ""
					},
					dimension_names : {
						type : "Array",
						value : "null"
					},
					period : {
						type : "int",
						value : "0"
					},
					statistic : {
						type : "String",
						value : "null"
					},
					unit : {
						type : "String",
						value : "null"
					}
				}
			}
		}
	},
	EC2 : {
		EC2 : {
			DescribeRegions : {
				method : "/aws/ec2:DescribeRegions",
				param : {
					region_names : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			},
			DescribeAvailabilityZones : {
				method : "/aws/ec2:DescribeAvailabilityZones",
				param : {
					zone_names : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			},
			CreateTags : {
				method : "/aws/ec2:CreateTags",
				param : {
					resource_ids : {
						type : "Array",
						value : ""
					},
					tags : {
						type : "Array",
						value : ""
					}
				}
			},
			DescribeTags : {
				method : "/aws/ec2:DescribeTags",
				param : {
					filters : {
						type : "Array",
						value : "null"
					}
				}
			},
			DeleteTags : {
				method : "/aws/ec2:DeleteTags",
				param : {
					resource_ids : {
						type : "Array",
						value : ""
					},
					tags : {
						type : "Array",
						value : ""
					}
				}
			}
		},
		EIP : {
			AllocateAddress : {
				method : "/aws/ec2/elasticip:AllocateAddress",
				param : {
					domain : {
						type : "String",
						value : "null"
					}
				}
			},
			ReleaseAddress : {
				method : "/aws/ec2/elasticip:ReleaseAddress",
				param : {
					ip : {
						type : "String",
						value : "null"
					},
					allocation_id : {
						type : "String",
						value : "null"
					}
				}
			},
			AssociateAddress : {
				method : "/aws/ec2/elasticip:AssociateAddress",
				param : {
					instance_id : {
						type : "String",
						value : ""
					},
					ip : {
						type : "String",
						value : "null"
					},
					allocation_id : {
						type : "String",
						value : "null"
					}
				}
			},
			DisassociateAddress : {
				method : "/aws/ec2/elasticip:DisassociateAddress",
				param : {
					ip : {
						type : "String",
						value : "null"
					},
					association_id : {
						type : "String",
						value : "null"
					}
				}
			},
			DescribeAddresses : {
				method : "/aws/ec2/elasticip:DescribeAddresses",
				param : {
					ips : {
						type : "Array",
						value : "null"
					},
					allocation_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Dictionary",
						value : "null"
					}
				}
			}
		},
		Instance : {
			RunInstances : {
				method : "/aws/ec2/instance:RunInstances",
				param : {
					ami_id : {
						type : "String",
						value : ""
					},
					min_count : {
						type : "int",
						value : "1"
					},
					max_count : {
						type : "int",
						value : "1"
					},
					key_name : {
						type : "String",
						value : "null"
					},
					security_group_ids : {
						type : "Array",
						value : "null"
					},
					security_group_names : {
						type : "Array",
						value : "null"
					},
					user_data : {
						type : "String",
						value : "null"
					},
					instance_type : {
						type : "String",
						value : "'m1.small'"
					},
					placement : {
						type : "Dictionary",
						value : "null"
					},
					kernel_id : {
						type : "String",
						value : "null"
					},
					ramdisk_id : {
						type : "String",
						value : "null"
					},
					block_device_map : {
						type : "Array",
						value : "null"
					},
					monitoring_enabled : {
						type : "Boolean",
						value : "false"
					},
					subnet_id : {
						type : "String",
						value : "null"
					},
					disable_api_termination : {
						type : "Boolean",
						value : "false"
					},
					instance_initiated_shutdown_behavior : {
						type : "String",
						value : "'stop'"
					},
					private_ip_address : {
						type : "String",
						value : "null"
					},
					client_token : {
						type : "String",
						value : "null"
					}
				}
			},
			StartInstances : {
				method : "/aws/ec2/instance:StartInstances",
				param : {
					instance_ids : {
						type : "Array",
						value : "null"
					}
				}
			},
			StopInstances : {
				method : "/aws/ec2/instance:StopInstances",
				param : {
					instance_ids : {
						type : "Array",
						value : "null"
					},
					force : {
						type : "Boolean",
						value : "false"
					}
				}
			},
			RebootInstances : {
				method : "/aws/ec2/instance:RebootInstances",
				param : {
					instance_ids : {
						type : "Array",
						value : "null"
					}
				}
			},
			TerminateInstances : {
				method : "/aws/ec2/instance:TerminateInstances",
				param : {
					instance_ids : {
						type : "Array",
						value : "null"
					}
				}
			},
			MonitorInstances : {
				method : "/aws/ec2/instance:MonitorInstances",
				param : {
					instance_ids : {
						type : "Array",
						value : ""
					}
				}
			},
			UnmonitorInstances : {
				method : "/aws/ec2/instance:UnmonitorInstances",
				param : {
					instance_ids : {
						type : "Array",
						value : ""
					}
				}
			},
			ModifyInstanceAttribute : {
				method : "/aws/ec2/instance:ModifyInstanceAttribute",
				param : {
					instance_id : {
						type : "String",
						value : ""
					},
					attribute_name : {
						type : "String",
						value : ""
					},
					attribute_value : {
						type : "String",
						value : ""
					}
				}
			},
			ResetInstanceAttribute : {
				method : "/aws/ec2/instance:ResetInstanceAttribute",
				param : {
					instance_id : {
						type : "String",
						value : ""
					},
					attribute_name : {
						type : "String",
						value : ""
					}
				}
			},
			ConfirmProductInstance : {
				method : "/aws/ec2/instance:ConfirmProductInstance",
				param : {
					instance_id : {
						type : "String",
						value : "null"
					},
					product_code : {
						type : "String",
						value : "null"
					}
				}
			},
			GetConsoleOutput : {
				method : "/aws/ec2/instance:GetConsoleOutput",
				param : {
					instance_id : {
						type : "String",
						value : ""
					}
				}
			},
			DescribeInstanceAttribute : {
				method : "/aws/ec2/instance:DescribeInstanceAttribute",
				param : {
					instance_id : {
						type : "String",
						value : ""
					},
					attribute_name : {
						type : "String",
						value : ""
					}
				}
			},
			DescribeInstances : {
				method : "/aws/ec2/instance:DescribeInstances",
				param : {
					instance_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Dictionary",
						value : "null"
					}
				}
			},
			DescribeBundleTasks : {
				method : "/aws/ec2/instance:DescribeBundleTasks",
				param : {
					bundle_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Dictionary",
						value : "null"
					}
				}
			},
			GetPasswordData : {
				method : "/aws/ec2/instance:GetPasswordData",
				param : {
					instance_id : {
						type : "String",
						value : ""
					},
					pem : {
						type : "String",
						value : ""
					}
				}
			}
		},
		KeyPair : {
			CreateKeyPair : {
				method : "/aws/ec2/keypair:CreateKeyPair",
				param : {
					key_name : {
						type : "String",
						value : ""
					}
				}
			},
			DeleteKeyPair : {
				method : "/aws/ec2/keypair:DeleteKeyPair",
				param : {
					key_name : {
						type : "String",
						value : ""
					}
				}
			},
			ImportKeyPair : {
				method : "/aws/ec2/keypair:ImportKeyPair",
				param : {
					key_name : {
						type : "String",
						value : ""
					},
					key_data : {
						type : "String",
						value : ""
					}
				}
			},
			DescribeKeyPairs : {
				method : "/aws/ec2/keypair:DescribeKeyPairs",
				param : {
					key_names : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Dictionary",
						value : "null"
					}
				}
			},
			upload : {
				method : "/aws/ec2/keypair:upload",
				param : {
					key_name : {
						type : "String",
						value : ""
					},
					key_data : {
						type : "String",
						value : ""
					}
				}
			},
			download : {
				method : "/aws/ec2/keypair:download",
				param : {
					key_name : {
						type : "String",
						value : ""
					}
				}
			},
			remove : {
				method : "/aws/ec2/keypair:remove",
				param : {
					key_name : {
						type : "String",
						value : ""
					}
				}
			},
			list : {
				method : "/aws/ec2/keypair:list",
				param : {
				}
			}
		},
		PlacementGroup : {
			CreatePlacementGroup : {
				method : "/aws/ec2/placementgroup:CreatePlacementGroup",
				param : {
					group_name : {
						type : "String",
						value : ""
					},
					strategy : {
						type : "String",
						value : "'cluster'"
					}
				}
			},
			DeletePlacementGroup : {
				method : "/aws/ec2/placementgroup:DeletePlacementGroup",
				param : {
					group_name : {
						type : "String",
						value : ""
					}
				}
			},
			DescribePlacementGroups : {
				method : "/aws/ec2/placementgroup:DescribePlacementGroups",
				param : {
					group_names : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Dictionary",
						value : "null"
					}
				}
			}
		},
		SecurityGroup : {
			CreateSecurityGroup : {
				method : "/aws/ec2/securitygroup:CreateSecurityGroup",
				param : {
					group_name : {
						type : "String",
						value : ""
					},
					group_desc : {
						type : "String",
						value : ""
					},
					vpc_id : {
						type : "String",
						value : "null"
					}
				}
			},
			DeleteSecurityGroup : {
				method : "/aws/ec2/securitygroup:DeleteSecurityGroup",
				param : {
					group_name : {
						type : "String",
						value : ""
					},
					group_id : {
						type : "String",
						value : "null"
					}
				}
			},
			AuthorizeSecurityGroupIngress : {
				method : "/aws/ec2/securitygroup:AuthorizeSecurityGroupIngress",
				param : {
					group_name : {
						type : "String",
						value : "null"
					},
					group_id : {
						type : "String",
						value : "null"
					},
					ip_permissions : {
						type : "Array",
						value : "null"
					}
				}
			},
			RevokeSecurityGroupIngress : {
				method : "/aws/ec2/securitygroup:RevokeSecurityGroupIngress",
				param : {
					group_name : {
						type : "String",
						value : "null"
					},
					group_id : {
						type : "String",
						value : "null"
					},
					ip_permissions : {
						type : "Array",
						value : "null"
					}
				}
			},
			DescribeSecurityGroups : {
				method : "/aws/ec2/securitygroup:DescribeSecurityGroups",
				param : {
					group_names : {
						type : "Array",
						value : "null"
					},
					group_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		},
		Snapshot : {
			CreateSnapshot : {
				method : "/aws/ec2/ebs/snapshot:CreateSnapshot",
				param : {
					volume_id : {
						type : "String",
						value : ""
					},
					description : {
						type : "String",
						value : "null"
					}
				}
			},
			DeleteSnapshot : {
				method : "/aws/ec2/ebs/snapshot:DeleteSnapshot",
				param : {
					snapshot_id : {
						type : "String",
						value : ""
					}
				}
			},
			ModifySnapshotAttribute : {
				method : "/aws/ec2/ebs/snapshot:ModifySnapshotAttribute",
				param : {
					snapshot_id : {
						type : "String",
						value : ""
					},
					user_ids : {
						type : "Array",
						value : "null"
					},
					group_names : {
						type : "Array",
						value : "null"
					}
				}
			},
			ResetSnapshotAttribute : {
				method : "/aws/ec2/ebs/snapshot:ResetSnapshotAttribute",
				param : {
					snapshot_id : {
						type : "String",
						value : ""
					},
					attribute_name : {
						type : "String",
						value : "'createVolumePermission'"
					}
				}
			},
			DescribeSnapshotAttribute : {
				method : "/aws/ec2/ebs/snapshot:DescribeSnapshotAttribute",
				param : {
					snapshot_id : {
						type : "String",
						value : ""
					},
					attribute_name : {
						type : "String",
						value : "'createVolumePermission'"
					}
				}
			},
			DescribeSnapshots : {
				method : "/aws/ec2/ebs/snapshot:DescribeSnapshots",
				param : {
					snapshot_ids : {
						type : "Array",
						value : "null"
					},
					owners : {
						type : "Array",
						value : "null"
					},
					restorable_by : {
						type : "String",
						value : "null"
					},
					filters : {
						type : "Dictionary",
						value : "null"
					}
				}
			}
		},
		Volume : {
			CreateVolume : {
				method : "/aws/ec2/ebs/volume:CreateVolume",
				param : {
					zone_name : {
						type : "String",
						value : ""
					},
					snapshot_id : {
						type : "String",
						value : "null"
					},
					volume_size : {
						type : "int",
						value : "0"
					}
				}
			},
			DeleteVolume : {
				method : "/aws/ec2/ebs/volume:DeleteVolume",
				param : {
					volume_id : {
						type : "String",
						value : ""
					}
				}
			},
			AttachVolume : {
				method : "/aws/ec2/ebs/volume:AttachVolume",
				param : {
					volume_id : {
						type : "String",
						value : ""
					},
					instance_id : {
						type : "String",
						value : ""
					},
					device : {
						type : "String",
						value : ""
					}
				}
			},
			DetachVolume : {
				method : "/aws/ec2/ebs/volume:DetachVolume",
				param : {
					volume_id : {
						type : "String",
						value : ""
					},
					instance_id : {
						type : "String",
						value : "null"
					},
					device : {
						type : "String",
						value : "null"
					},
					force : {
						type : "Boolean",
						value : "false"
					}
				}
			},
			DescribeVolumes : {
				method : "/aws/ec2/ebs/volume:DescribeVolumes",
				param : {
					volume_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		}
	},
	ELB : {
		LoadBalancer : {
			DescribeInstanceHealth : {
				method : "/aws/elb:DescribeInstanceHealth",
				param : {
					elb_name : {
						type : "String",
						value : ""
					},
					instance_ids : {
						type : "Array",
						value : "null"
					}
				}
			},
			DescribeLoadBalancerPolicies : {
				method : "/aws/elb:DescribeLoadBalancerPolicies",
				param : {
					elb_name : {
						type : "String",
						value : "null"
					},
					policy_names : {
						type : "Array",
						value : "null"
					}
				}
			},
			DescribeLoadBalancerPolicyTypes : {
				method : "/aws/elb:DescribeLoadBalancerPolicyTypes",
				param : {
					policy_type_names : {
						type : "Array",
						value : "null"
					}
				}
			},
			DescribeLoadBalancers : {
				method : "/aws/elb:DescribeLoadBalancers",
				param : {
					elb_names : {
						type : "Array",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					}
				}
			}
		}
	},
	IAM : {
		IAM : {
			GetAccountPasswordPolicy : {
				method : "/aws/iam:GetAccountPasswordPolicy",
				param : {
				}
			},
			GetAccountSummary : {
				method : "/aws/iam:GetAccountSummary",
				param : {
				}
			},
			GetGroup : {
				method : "/aws/iam:GetGroup",
				param : {
					group_name : {
						type : "String",
						value : ""
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			GetGroupPolicy : {
				method : "/aws/iam:GetGroupPolicy",
				param : {
					group_name : {
						type : "String",
						value : ""
					},
					policy_name : {
						type : "String",
						value : ""
					}
				}
			},
			GetInstanceProfile : {
				method : "/aws/iam:GetInstanceProfile",
				param : {
					instance_profile_name : {
						type : "String",
						value : ""
					}
				}
			},
			GetLoginProfile : {
				method : "/aws/iam:GetLoginProfile",
				param : {
					user_name : {
						type : "String",
						value : ""
					}
				}
			},
			GetRole : {
				method : "/aws/iam:GetRole",
				param : {
					role_name : {
						type : "String",
						value : ""
					}
				}
			},
			GetRolePolicy : {
				method : "/aws/iam:GetRolePolicy",
				param : {
					policy_name : {
						type : "String",
						value : ""
					},
					role_name : {
						type : "String",
						value : ""
					}
				}
			},
			GetServerCertificate : {
				method : "/aws/iam:GetServerCertificate",
				param : {
					cert_name : {
						type : "String",
						value : ""
					}
				}
			},
			GetUser : {
				method : "/aws/iam:GetUser",
				param : {
					user_name : {
						type : "String",
						value : ""
					}
				}
			},
			GetUserPolicy : {
				method : "/aws/iam:GetUserPolicy",
				param : {
					policy_name : {
						type : "String",
						value : ""
					},
					user_name : {
						type : "String",
						value : ""
					}
				}
			},
			ListAccessKeys : {
				method : "/aws/iam:ListAccessKeys",
				param : {
					user_name : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListAccountAliases : {
				method : "/aws/iam:ListAccountAliases",
				param : {
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListGroupPolicies : {
				method : "/aws/iam:ListGroupPolicies",
				param : {
					group_name : {
						type : "String",
						value : ""
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListGroups : {
				method : "/aws/iam:ListGroups",
				param : {
					path_prefix : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListGroupsForUser : {
				method : "/aws/iam:ListGroupsForUser",
				param : {
					user_name : {
						type : "String",
						value : ""
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListInstanceProfiles : {
				method : "/aws/iam:ListInstanceProfiles",
				param : {
					path_prefix : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListInstanceProfilesForRole : {
				method : "/aws/iam:ListInstanceProfilesForRole",
				param : {
					role_name : {
						type : "String",
						value : ""
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListMFADevices : {
				method : "/aws/iam:ListMFADevices",
				param : {
					user_name : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListRolePolicies : {
				method : "/aws/iam:ListRolePolicies",
				param : {
					role_name : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListRoles : {
				method : "/aws/iam:ListRoles",
				param : {
					path_prefix : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListServerCertificates : {
				method : "/aws/iam:ListServerCertificates",
				param : {
					path_prefix : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListSigningCertificates : {
				method : "/aws/iam:ListSigningCertificates",
				param : {
					user_name : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListUserPolicies : {
				method : "/aws/iam:ListUserPolicies",
				param : {
					user_name : {
						type : "String",
						value : ""
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListUsers : {
				method : "/aws/iam:ListUsers",
				param : {
					path_prefix : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			},
			ListVirtualMFADevices : {
				method : "/aws/iam:ListVirtualMFADevices",
				param : {
					assignment_status : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_items : {
						type : "int",
						value : "NaN"
					}
				}
			}
		}
	},
	RDS : {
		DBInstance : {
			DescribeDBInstances : {
				method : "/aws/rds/instance:DescribeDBInstances",
				param : {
					instance_id : {
						type : "String",
						value : ""
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			}
		},
		DBParameterGroup : {
			DescribeDBParameterGroups : {
				method : "/aws/rds/parametergroup:DescribeDBParameterGroups",
				param : {
					pg_name : {
						type : "String",
						value : ""
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			},
			DescribeDBParameters : {
				method : "/aws/rds/parametergroup:DescribeDBParameters",
				param : {
					pg_name : {
						type : "String",
						value : ""
					},
					source : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			}
		},
		DBSecurityGroup : {
			DescribeDBSecurityGroups : {
				method : "/aws/rds/securitygroup:DescribeDBSecurityGroups",
				param : {
					sg_name : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			}
		},
		DBSnapshot : {
			DescribeDBSnapshots : {
				method : "/aws/rds/snapshot:DescribeDBSnapshots",
				param : {
					instance_id : {
						type : "String",
						value : "null"
					},
					snapshot_id : {
						type : "String",
						value : "null"
					},
					snapshot_type : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			}
		},
		DBSubnetGroup : {
			DescribeDBSubnetGroups : {
				method : "/aws/rds/subnetgroup:DescribeDBSubnetGroups",
				param : {
					sg_name : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			}
		},
		OptionGroup : {
			DescribeOptionGroupOptions : {
				method : "/aws/rds/optiongroup:DescribeOptionGroupOptions",
				param : {
					engine_name : {
						type : "String",
						value : ""
					},
					major_engine_version : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			},
			DescribeOptionGroups : {
				method : "/aws/rds/optiongroup:DescribeOptionGroups",
				param : {
					op_name : {
						type : "String",
						value : "null"
					},
					engine_name : {
						type : "String",
						value : "null"
					},
					major_engine_version : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			}
		},
		RDS : {
			DescribeDBEngineVersions : {
				method : "/aws/rds/rds:DescribeDBEngineVersions",
				param : {
					pg_family : {
						type : "String",
						value : "null"
					},
					default_only : {
						type : "Boolean",
						value : "false"
					},
					engine : {
						type : "String",
						value : "null"
					},
					engine_version : {
						type : "String",
						value : "null"
					},
					list_supported_character_set : {
						type : "Boolean",
						value : "false"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			},
			DescribeOrderableDBInstanceOptions : {
				method : "/aws/rds/rds:DescribeOrderableDBInstanceOptions",
				param : {
					engine : {
						type : "String",
						value : ""
					},
					engine_version : {
						type : "String",
						value : "null"
					},
					instance_class : {
						type : "String",
						value : "null"
					},
					license_model : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			},
			DescribeEngineDefaultParameters : {
				method : "/aws/rds/rds:DescribeEngineDefaultParameters",
				param : {
					pg_family : {
						type : "String",
						value : ""
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			},
			DescribeEvents : {
				method : "/aws/rds/rds:DescribeEvents",
				param : {
					duration : {
						type : "int",
						value : "0"
					},
					start_time : {
						type : "Date",
						value : "null"
					},
					end_time : {
						type : "Date",
						value : "null"
					},
					source_id : {
						type : "String",
						value : "null"
					},
					source_type : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			}
		},
		ReservedDBInstance : {
			DescribeReservedDBInstances : {
				method : "/aws/rds/reservedinstance:DescribeReservedDBInstances",
				param : {
					instance_id : {
						type : "String",
						value : "null"
					},
					instance_class : {
						type : "String",
						value : "null"
					},
					offering_id : {
						type : "String",
						value : "null"
					},
					offering_type : {
						type : "String",
						value : "null"
					},
					duration : {
						type : "String",
						value : "null"
					},
					multi_az : {
						type : "Boolean",
						value : "false"
					},
					description : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			},
			DescribeReservedDBInstancesOfferings : {
				method : "/aws/rds/reservedinstance:DescribeReservedDBInstancesOfferings",
				param : {
					offering_id : {
						type : "String",
						value : "null"
					},
					offering_type : {
						type : "String",
						value : "null"
					},
					instance_class : {
						type : "String",
						value : "null"
					},
					duration : {
						type : "String",
						value : "null"
					},
					multi_az : {
						type : "Boolean",
						value : "false"
					},
					description : {
						type : "String",
						value : "null"
					},
					marker : {
						type : "String",
						value : "null"
					},
					max_records : {
						type : "int",
						value : "0"
					}
				}
			}
		}
	},
	SDB : {
		SDB : {
			DomainMetadata : {
				method : "/aws/sdb:DomainMetadata",
				param : {
					domain_name : {
						type : "String",
						value : ""
					}
				}
			},
			GetAttributes : {
				method : "/aws/sdb:GetAttributes",
				param : {
					domain_name : {
						type : "String",
						value : ""
					},
					item_name : {
						type : "String",
						value : ""
					},
					attribute_name : {
						type : "String",
						value : "null"
					},
					consistent_read : {
						type : "Boolean",
						value : "false"
					}
				}
			},
			ListDomains : {
				method : "/aws/sdb:ListDomains",
				param : {
					max_domains : {
						type : "int",
						value : "0"
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			}
		}
	},
	SNS : {
		SNS : {
			GetSubscriptionAttributes : {
				method : "/aws/sns:GetSubscriptionAttributes",
				param : {
					subscription_arn : {
						type : "String",
						value : ""
					}
				}
			},
			GetTopicAttributes : {
				method : "/aws/sns:GetTopicAttributes",
				param : {
					topic_arn : {
						type : "String",
						value : ""
					}
				}
			},
			ListSubscriptions : {
				method : "/aws/sns:ListSubscriptions",
				param : {
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			ListSubscriptionsByTopic : {
				method : "/aws/sns:ListSubscriptionsByTopic",
				param : {
					topic_arn : {
						type : "String",
						value : ""
					},
					next_token : {
						type : "String",
						value : "null"
					}
				}
			},
			ListTopics : {
				method : "/aws/sns:ListTopics",
				param : {
					next_token : {
						type : "String",
						value : "null"
					}
				}
			}
		}
	},
	VPC : {
		ACL : {
			DescribeNetworkAcls : {
				method : "/aws/vpc/acl:DescribeNetworkAcls",
				param : {
					acl_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		},
		CustomerGateway : {
			DescribeCustomerGateways : {
				method : "/aws/vpc/cgw:DescribeCustomerGateways",
				param : {
					gw_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		},
		DHCP : {
			DescribeDhcpOptions : {
				method : "/aws/vpc/dhcp:DescribeDhcpOptions",
				param : {
					dhcp_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		},
		ENI : {
			DescribeNetworkInterfaces : {
				method : "/aws/vpc/eni:DescribeNetworkInterfaces",
				param : {
					eni_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			},
			DescribeNetworkInterfaceAttribute : {
				method : "/aws/vpc/eni:DescribeNetworkInterfaceAttribute",
				param : {
					eni_id : {
						type : "String",
						value : ""
					},
					attribute : {
						type : "String",
						value : ""
					}
				}
			}
		},
		InternetGateway : {
			DescribeInternetGateways : {
				method : "/aws/vpc/igw:DescribeInternetGateways",
				param : {
					gw_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		},
		RouteTable : {
			DescribeRouteTables : {
				method : "/aws/vpc/routetable:DescribeRouteTables",
				param : {
					rt_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		},
		Subnet : {
			DescribeSubnets : {
				method : "/aws/vpc/subnet:DescribeSubnets",
				param : {
					subnet_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		},
		VPC : {
			DescribeVpcs : {
				method : "/aws/vpc:DescribeVpcs",
				param : {
					vpc_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			},
			DescribeAccountAttributes : {
				method : "/aws/vpc:DescribeAccountAttributes",
				param : {
					attribute_name : {
						type : "Array",
						value : "null"
					}
				}
			},
			DescribeVpcAttribute : {
				method : "/aws/vpc:DescribeVpcAttribute",
				param : {
					attribute : {
						type : "String",
						value : "null"
					}
				}
			}
		},
		VPN : {
			DescribeVpnConnections : {
				method : "/aws/vpc/vpn:DescribeVpnConnections",
				param : {
					vpn_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		},
		VPNGateway : {
			DescribeVpnGateways : {
				method : "/aws/vpc/vgw:DescribeVpnGateways",
				param : {
					gw_ids : {
						type : "Array",
						value : "null"
					},
					filters : {
						type : "Array",
						value : "null"
					}
				}
			}
		}
	}
}
