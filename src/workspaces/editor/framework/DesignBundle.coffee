

(()->
    deps = [
        'Design',
        "CanvasManager",

        './connection/EniAttachment',
        './connection/VPNConnection',
        './resource/InstanceModel',
        './resource/EniModel',
        './resource/VolumeModel',
        './resource/AclModel',
        './resource/AsgModel',
        './resource/AzModel',
        './resource/AzModel',
        './resource/CgwModel',
        './resource/ElbModel',
        './resource/LcModel',
        './resource/KeypairModel',
        './resource/SslCertModel',
        './resource/RtbModel',
        './resource/SgModel',
        './resource/SubnetModel',
        './resource/VpcModel',
        './resource/IgwModel',
        './resource/VgwModel',
        './resource/SnsModel',
        './resource/StorageModel',
        './resource/ScalingPolicyModel',

        "./util/deserializeVisitor/JsonFixer",
        "./util/deserializeVisitor/EipMerge",
        "./util/deserializeVisitor/FixOldStack",
        "./util/deserializeVisitor/AsgExpandor",
        "./util/deserializeVisitor/ElbSgNamePatch",
        "./util/serializeVisitor/EniIpAssigner",
        "./util/serializeVisitor/AppToStack",
    ]

    ### env:dev ###
    deps.push "./util/DesignDebugger"
    ### env:dev:end ###

    ### env:debug ###
    deps.push "./util/DesignDebugger"
    ### env:debug:end ###

    define deps, ( Design )->
        window.Design = Design
        Design

)()
