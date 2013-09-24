module.exports = {

    /*add by xjimmy*/
    dist: {
        files: {
            "release/js/main.js": "release/js/main.js",
            "release/service/aws/ec2/instance/instance_parser.js": "release/service/aws/ec2/instance/instance_parser.js",
            "release/service/session/session_parser.js": "release/service/session/session_parser.js"
        },
        options: {
            replacements: [
                {
                    pattern: /console\.(log|info|error)\(.*\),/g,
                    replacement: ""
                }
            ]
        }
    }
};