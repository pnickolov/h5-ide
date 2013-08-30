-------------------------------------------------------------------------
deploy£º
-------------------------------------------------------------------------
[step 1]copy shell script to 26.7
copy sh/* to 26.7 /root/xjimmy

[step 2]add the following line to crontab of 26.7 (crontab -e)
*/2 * * * * su - root -c "/root/xjimmy/check.sh > /dev/null 2>&1"

[step 3]add git hook to 26.6
copy post-receive.exp to /opt/source/html5/ide.git/hooks
#ln -s post-receive.exp post-receive

done.

-------------------------------------------------------------------------
config no key for ssh from 26.6 to 26.7:
-------------------------------------------------------------------------
[step 1] create public & private key on 26.6
cd ~/.ssh
ssh-keygen

[step 2] create authorized_keys on 26.7
touch authorized_keys
chmod 600 authorized_keys

[step 3] add id_rsa.pub's content of 26.6 to authorized_keys of 26.7


done.


--------------------------------------------------------------------------
auto build process
--------------------------------------------------------------------------

1. git push to 26.6 trigger post-receive

2. post-receive write 1 to /root/xjimmy/etc/needbuild of 26.7

3. cron task run /root/xjimmy/check.sh every 2 minutes

4. check.sh will kill current build.sh , and run build.sh again

5. build.sh will pull code from 26.6, and kill current "grunt dev_all", then run "grunt dev_all" again

6. wait for several minutes , autobuild will be complete

