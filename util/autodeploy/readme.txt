[deploy to demo]

1.cp sh/check.sh to remote
/root/ec2-user

2.create dir
mkdir -p /root/ec2-user/ide
mkdir -p /root/ec2-user/log

3.add to crontab
*/1 * * * * su - root -c "/home/ec2-user/check.sh > /dev/null 2>&1"

4.usage
./util/autodeploy/deploy-demo.sh
