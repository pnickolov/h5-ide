
define [
  "constant"
  "CloudResources"
  "./CrSubCollection"
], ( constant, CloudResources )->

  return

  DhcpCollection = CloudResources( constant.RESTYPE.DHCP, "us-west-2" )
  DhcpCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info DhcpCollection

  CertCollection = CloudResources( constant.RESTYPE.IAM, "us-west-2" )
  CertCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info CertCollection

  TopicCollection = CloudResources( constant.RESTYPE.TOPIC, "us-west-2" )
  TopicCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info TopicCollection

  SubsCollection = CloudResources( constant.RESTYPE.SUBSCRIPTION, "us-west-2" )
  SubsCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info SubsCollection


  SnapCollection = CloudResources( constant.RESTYPE.SNAP, "us-east-1" )
  SnapCollection.on "update", ()->
    console.log "=============="
    console.log "=============="
    console.info SnapCollection

  DhcpCollection.fetch()
  CertCollection.fetch()
  TopicCollection.fetch()
  SubsCollection.fetch()
  SnapCollection.fetch()

  window.CrTestcase =

    RemoveResources : ()->
      if DhcpCollection.get("dopt-9e6172fc")
        DhcpCollection.get("dopt-9e6172fc").destroy()

      if CertCollection.findWhere({Name:"MorrisTestCert2"})
        CertCollection.findWhere({Name:"MorrisTestCert2"}).destroy()

      if TopicCollection.get("arn:aws:sns:us-west-2:994554139310:MorrisTestTopic")
        TopicCollection.get("arn:aws:sns:us-west-2:994554139310:MorrisTestTopic").destroy()

      # SubsCollection.findWhere({SubscriptionArn:"arn:aws:sns:us-west-2:994554139310:MorrisTestTopic"})

    RemoveResourcesFail : ()->


    CreateResourcesFail : ()->
      DhcpCollection.create({
        "netbios-node-type"    : "abc"
      }).save()

      TopicCollection.create({
        Name        : ""
      }).save()

      SubsCollection.create({
        Endpoint : "morris@mc2.io"
        Protocol : "email"
        TopicArn : "arn:aws:sns:us-west-2:994554139310:MorrisTestTopicNoneExist"
      }).save()

      CertCollection.create({
        Name             : "MorrisTestCert2"
        PrivateKey       : ""
        CertificateBody  : ""
      }).save()

    CreateResources : ()->
      DhcpCollection.create({
        "netbios-node-type"    : ["2"]
        "ntp-servers"          : ["4.4.4.4","3.3.3.3"]
        "domain-name"          : ["www.abc2.com","www.abc.com"]
        "domain-name-servers"  : ["12.12.12.12","13.13.13.13"]
        "netbios-name-servers" : ["13.13.13.13","200.200.200.200"]
      }).save()

      TopicCollection.create({
        Name        : "MorrisTestTopic"
        DisplayName : "MorrisTestTopic"
      }).save()

      SubsCollection.create({
        Endpoint        : "morris@mc2.io"
        Protocol        : "email"
        TopicArn        : "arn:aws:sns:us-west-2:994554139310:MorrisTestTopic"
      }).save()

      CertCollection.create({
        Name             : "MorrisTestCert2"
        PrivateKey       : """
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA2PSMweBuIoF+FG6M24FGiSLZ6l4E5hHkdwpYg/LEE0s5RJ5W
DUJWt16ixTscYcDK/AoXjSWaN7StyVQ3hHsb9EVlk5ljEISF0DoFMvGqTBATB/Za
E2TqiVXRUZaaQTFxBgiA5Bme8RDUFr2hpS79NPJ5JZU+qLsamZ/EaJm/8xg3sckY
9zG/SMYvktMw0Kwb+3Sdn8dZSa3/8FhATEpemAMYCXTzI04hfq5kbLlveklSDsnw
3vBmMo4pZVnqyd2LGNOITFy7T+R9yQiK3i+yF4c9KIJgGGtIC+9kajU7kMCrmAhq
2s/a/RN7Oq+hWx2uz0mmWCIe7pLr0HJvC1tqhwIDAQABAoIBAQCd102Qv/dgo1VX
CBbym9r1aqWgHUbzG5FcCercFIMShmfjxE5W1yy/u9owJBFCDUGgnLcFuZW5cXn+
P4ckm2x7CwIboDyyh7fTBmNB7RA4xnkSEej2szTvNcBT233ecFoKSaV8TieUuumS
oeQ4iTcujjoVXb94gqeXnOUINNOxx1T3ab4r9JzJDim7hnns3I79XVHVF2NYh3z2
6ZW5PeHr94Dn4hoswSDRPqDSJmpenmO9jAxgD4RfpeoOX5u8vw48L48kCYINIpZ9
z1fvmajFn2xFCBOsuKKi6YCXBeBMytwXZeDPbCHOVAsYizVJJOKCVCcARwRJhWpk
zqeJE3wBAoGBAPzrjfbURp4FSY95LTBFXM5cPsVA0k7CIiLZ5fULr+11PeKdy2Sc
LtdpDmJXCLh312Y2Q1oRehNQRpuG8I+009+uoGufP4saOifwUJMxt1WQ3fVc/Cqq
PFFFU65pv2BfMObgRphcwxpCvrZkCwLmVwP99rvaB8TPAnaroDcxrYoJAoGBANuY
4Sjkcyh+BBWRUH8Q294mBEgfKlfuZ1L1mF5O7iPwdvcOWiskAwoSXROE/FS0vSmM
VAXmZaJZ+i/HVjr5D3PF9Yrf1op2EesmLK7UwGRC7Fzna53zyYMrkY4jea7EDrCa
idp0A+Xed1ajqrreIM5YEx+lB22e/ythrhJEkrQPAoGBALIVJYtzYhmnvWjROLkx
TaxblTMMdkhQNvr1FA6bYQ9AqwdidbDsq6qu5RrnD1PbxgXJFVlYzuzEbELcG4wE
Fd78tSWyJmrKV8KBWiqaKe2MqEw4YbGk1f2fY9F90euIewVFS0/CmPlnn6MLBBnR
l9lOu6j/VtMDs0ddhtz2FKwJAoGAV7PBCRHkJCHgA7UbjwPuq9RHFX7M7H1careH
ePLRDS12dckXne8t/5HB9o/ALxxYCAXxcMHJiYOh9f8Io1jhIP3IyQQIrRfmpCGE
6vYxOFm6CIisZFL/AhIeecQVTwUiUMoHkGWRQPcOdl27TBJ2y7JFQPgp9U/w3SSP
3t/gL2UCgYBRIUMm9Vg06YOzYES2YWpoZfpPevCO4j+dS2MjoTGJ/MTn29ASjrrd
rkhulebUMEcSDwGtaZUnnSsl+LlklqMlTJWTms4KaOxa64pitdc8zkR8F4iECzEe
wkI+YJ9kgWQZXQPKgSAiKiPq06nVUfbSp6lqApVHrCi4k5Q8XGoI6A==
-----END RSA PRIVATE KEY-----
"""
        CertificateBody  : """
-----BEGIN CERTIFICATE-----
MIIFATCCA+mgAwIBAgIQSHW5NjjFcwlWluD7RcFWVTANBgkqhkiG9w0BAQUFADBz
MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
VQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDEZMBcGA1UE
AxMQUG9zaXRpdmVTU0wgQ0EgMjAeFw0xNDAzMjUwMDAwMDBaFw0xNTAzMjUyMzU5
NTlaMFsxITAfBgNVBAsTGERvbWFpbiBDb250cm9sIFZhbGlkYXRlZDEdMBsGA1UE
CxMUUG9zaXRpdmVTU0wgV2lsZGNhcmQxFzAVBgNVBAMUDioudmlzdWFsb3BzLmlv
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2PSMweBuIoF+FG6M24FG
iSLZ6l4E5hHkdwpYg/LEE0s5RJ5WDUJWt16ixTscYcDK/AoXjSWaN7StyVQ3hHsb
9EVlk5ljEISF0DoFMvGqTBATB/ZaE2TqiVXRUZaaQTFxBgiA5Bme8RDUFr2hpS79
NPJ5JZU+qLsamZ/EaJm/8xg3sckY9zG/SMYvktMw0Kwb+3Sdn8dZSa3/8FhATEpe
mAMYCXTzI04hfq5kbLlveklSDsnw3vBmMo4pZVnqyd2LGNOITFy7T+R9yQiK3i+y
F4c9KIJgGGtIC+9kajU7kMCrmAhq2s/a/RN7Oq+hWx2uz0mmWCIe7pLr0HJvC1tq
hwIDAQABo4IBpzCCAaMwHwYDVR0jBBgwFoAUmeRAX2sUXj4F2d3TY1T8Yrj3AKww
HQYDVR0OBBYEFLXrdQPZF6zUlOKQfmkFy4jZ/U30MA4GA1UdDwEB/wQEAwIFoDAM
BgNVHRMBAf8EAjAAMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjBQBgNV
HSAESTBHMDsGCysGAQQBsjEBAgIHMCwwKgYIKwYBBQUHAgEWHmh0dHA6Ly93d3cu
cG9zaXRpdmVzc2wuY29tL0NQUzAIBgZngQwBAgEwOwYDVR0fBDQwMjAwoC6gLIYq
aHR0cDovL2NybC5jb21vZG9jYS5jb20vUG9zaXRpdmVTU0xDQTIuY3JsMGwGCCsG
AQUFBwEBBGAwXjA2BggrBgEFBQcwAoYqaHR0cDovL2NydC5jb21vZG9jYS5jb20v
UG9zaXRpdmVTU0xDQTIuY3J0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21v
ZG9jYS5jb20wJwYDVR0RBCAwHoIOKi52aXN1YWxvcHMuaW+CDHZpc3VhbG9wcy5p
bzANBgkqhkiG9w0BAQUFAAOCAQEAzhAURhFuwMaWXaKOTUuDE46NjA3gAhdmWcNt
9m97kddNMzwdLeCmzCAP5pVsSx4PMm1P+eWq46W1C2SObFCL3vLaWB9o4lt+ufmI
4fTsi76qIhm90IVDQdnz7V9UoyRcXMsKx7HnfaW16DHxjj0bvOjN9VBTzr8BF+fB
xjTxJiv1yOHxvpE1zn469VTAerDD9US2eusZlf6uh/uB/I4UTjq2LG9dBz+aTPre
WBkJsNi+RduPwjpNZ5S+kZev03jkhyvaDd1LDduJ3xayX/4ODZVGgp/xe9cxZt+D
e2xP6Y71oeEL+LVB1lMVMCUDB9zg+GiAmZ3QHv5y/ZabUOmm6w==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIE5TCCA82gAwIBAgIQB28SRoFFnCjVSNaXxA4AGzANBgkqhkiG9w0BAQUFADBv
MQswCQYDVQQGEwJTRTEUMBIGA1UEChMLQWRkVHJ1c3QgQUIxJjAkBgNVBAsTHUFk
ZFRydXN0IEV4dGVybmFsIFRUUCBOZXR3b3JrMSIwIAYDVQQDExlBZGRUcnVzdCBF
eHRlcm5hbCBDQSBSb290MB4XDTEyMDIxNjAwMDAwMFoXDTIwMDUzMDEwNDgzOFow
czELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4G
A1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxGTAXBgNV
BAMTEFBvc2l0aXZlU1NMIENBIDIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQDo6jnjIqaqucQA0OeqZztDB71Pkuu8vgGjQK3g70QotdA6voBUF4V6a4Rs
NjbloyTi/igBkLzX3Q+5K05IdwVpr95XMLHo+xoD9jxbUx6hAUlocnPWMytDqTcy
Ug+uJ1YxMGCtyb1zLDnukNh1sCUhYHsqfwL9goUfdE+SNHNcHQCgsMDqmOK+ARRY
FygiinddUCXNmmym5QzlqyjDsiCJ8AckHpXCLsDl6ez2PRIHSD3SwyNWQezT3zVL
yOf2hgVSEEOajBd8i6q8eODwRTusgFX+KJPhChFo9FJXb/5IC1tdGmpnc5mCtJ5D
YD7HWyoSbhruyzmuwzWdqLxdsC/DAgMBAAGjggF3MIIBczAfBgNVHSMEGDAWgBSt
vZh6NLQm9/rEJlTvA73gJMtUGjAdBgNVHQ4EFgQUmeRAX2sUXj4F2d3TY1T8Yrj3
AKwwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEQYDVR0gBAow
CDAGBgRVHSAAMEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwudXNlcnRydXN0
LmNvbS9BZGRUcnVzdEV4dGVybmFsQ0FSb290LmNybDCBswYIKwYBBQUHAQEEgaYw
gaMwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9BZGRUcnVz
dEV4dGVybmFsQ0FSb290LnA3YzA5BggrBgEFBQcwAoYtaHR0cDovL2NydC51c2Vy
dHJ1c3QuY29tL0FkZFRydXN0VVROU0dDQ0EuY3J0MCUGCCsGAQUFBzABhhlodHRw
Oi8vb2NzcC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQCcNuNOrvGK
u2yXjI9LZ9Cf2ISqnyFfNaFbxCtjDei8d12nxDf9Sy2e6B1pocCEzNFti/OBy59L
dLBJKjHoN0DrH9mXoxoR1Sanbg+61b4s/bSRZNy+OxlQDXqV8wQTqbtHD4tc0azC
e3chUN1bq+70ptjUSlNrTa24yOfmUlhNQ0zCoiNPDsAgOa/fT0JbHtMJ9BgJWSrZ
6EoYvzL7+i1ki4fKWyvouAt+vhcSxwOCKa9Yr4WEXT0K3yNRw82vEL+AaXeRCk/l
uuGtm87fM04wO+mPZn+C+mv626PAcwDj1hKvTfIPWhRRH224hoFiB85ccsJP81cq
cdnUl4XmGFO3
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIENjCCAx6gAwIBAgIBATANBgkqhkiG9w0BAQUFADBvMQswCQYDVQQGEwJTRTEU
MBIGA1UEChMLQWRkVHJ1c3QgQUIxJjAkBgNVBAsTHUFkZFRydXN0IEV4dGVybmFs
IFRUUCBOZXR3b3JrMSIwIAYDVQQDExlBZGRUcnVzdCBFeHRlcm5hbCBDQSBSb290
MB4XDTAwMDUzMDEwNDgzOFoXDTIwMDUzMDEwNDgzOFowbzELMAkGA1UEBhMCU0Ux
FDASBgNVBAoTC0FkZFRydXN0IEFCMSYwJAYDVQQLEx1BZGRUcnVzdCBFeHRlcm5h
bCBUVFAgTmV0d29yazEiMCAGA1UEAxMZQWRkVHJ1c3QgRXh0ZXJuYWwgQ0EgUm9v
dDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALf3GjPm8gAELTngTlvt
H7xsD821+iO2zt6bETOXpClMfZOfvUq8k+0DGuOPz+VtUFrWlymUWoCwSXrbLpX9
uMq/NzgtHj6RQa1wVsfwTz/oMp50ysiQVOnGXw94nZpAPA6sYapeFI+eh6FqUNzX
mk6vBbOmcZSccbNQYArHE504B4YCqOmoaSYYkKtMsE8jqzpPhNjfzp/haW+710LX
a0Tkx63ubUFfclpxCDezeWWkWaCUN/cALw3CknLa0Dhy2xSoRcRdKn23tNbE7qzN
E0S3ySvdQwAl+mG5aWpYIxG3pzOPVnVZ9c0p10a3CitlttNCbxWyuHv77+ldU9U0
WicCAwEAAaOB3DCB2TAdBgNVHQ4EFgQUrb2YejS0Jvf6xCZU7wO94CTLVBowCwYD
VR0PBAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wgZkGA1UdIwSBkTCBjoAUrb2YejS0
Jvf6xCZU7wO94CTLVBqhc6RxMG8xCzAJBgNVBAYTAlNFMRQwEgYDVQQKEwtBZGRU
cnVzdCBBQjEmMCQGA1UECxMdQWRkVHJ1c3QgRXh0ZXJuYWwgVFRQIE5ldHdvcmsx
IjAgBgNVBAMTGUFkZFRydXN0IEV4dGVybmFsIENBIFJvb3SCAQEwDQYJKoZIhvcN
AQEFBQADggEBALCb4IUlwtYj4g+WBpKdQZic2YR5gdkeWxQHIzZlj7DYd7usQWxH
YINRsPkyPef89iYTx4AWpb9a/IfPeHmJIZriTAcKhjW88t5RxNKWt9x+Tu5w/Rw5
6wwCURQtjr0W4MHfRnXnJK3s9EK0hZNwEGe6nQY1ShjTK3rMUUKhemPR5ruhxSvC
Nr4TDea9Y355e6cJDUCrat2PisP29owaQgVR1EX1n6diIWgVIEM8med8vSTYqZEX
c4g/VhsxOBi0cQ+azcgOno4uG+GMmIPLHzHxREzGBHNJdmAPx/i9F4BrLunMTA5a
mnkPIAou1Z5jJh5VkpTYghdae9C8x49OhgQ=
-----END CERTIFICATE-----
"""
      }).save()
