#!/usr/bin/env sh

pause() {
 echo "Compile Done"
}
coffee -c index.coffee model.coffee view.coffee jquery.atwho.coffee
pause


