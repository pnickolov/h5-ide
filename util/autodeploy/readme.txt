1.cp sh/check.sh to remote
/home/ec2-user/ide
chmod u+x /home/ec2-user/ide/check.sh

2.add to crontab
*/1 * * * * su - root -c "/home/ec2-user/ide/check.sh > /dev/null 2>&1"

3.usage
[deploy to 26.7]
./util/autodeploy/deploy.sh

[deploy to demo] ap-northeast-1
./util/autodeploy/deploy-demo.sh

[deploy to live] us-east-1
./util/autodeploy/deploy-live.sh

------------------------------------------------------------

publish dir: /madeira/site/ide_h5
backup dir:  /madeira/site/ide_h5.bak
			 /madeira/site/bak
temp dir:    /madeira/site/temp

/madeira/site/temp/ide.tar.gz
	-> /madeira/site/ide_h5.tmp/ide.tar.gz
		-> untar ide.tar.gz
			-> /madeira/site/ide_h5.tmp/ide.tar.gz to /madeira/site/bak
				-> /madeira/site/ide_h5 to /madeira/site/ide_h5.bak
					-> /madeira/site/ide_h5.tmp to /madeira/site/ide_h5