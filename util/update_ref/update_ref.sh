#!/bin/sh
################################
#app/update_ref.sh
#author:  xjimmy
#created: 2014-02-13
#update:  2014-02-18
#update reference of Stopped/Running app
#old reference:  @uuid.
#new reference: @{uuid}.
echo
echo "################################"
echo "#create "app" git repo"
echo "#[Step1] : export app [Running|Stopped]  to app.json from mongo"
echo "#[Step2] : json pretty"
echo "#[Step3] : [sed]replace '@uuid.' to '{@uuid.}'"
echo "#[Step4] : [sed]replace '{@' to '@{'"
echo "#[Step5] : [sed]replace '.}' to '}.'"
echo "#generate diff.log"
echo "#generate changed.log"
echo "#check changed line"
echo "################################"
echo 
function showlog (){
  STEP_=$1
  LOG_=$2
  echo -e "\n------------------------------------------------\n"
  echo  "[Step${STEP_}] : ${LOG_}"
}

function add2git (){
  MSG_=$1
  git add app-fmt.json
  git commit -m "${MSG_}"
}

function checkdiff() {
  DIFF_FILE=$1
  DIFF_TYPE=$2

  echo -e "\n${DIFF_FILE} ^${DIFF_TYPE}"
  if [ "${DIFF_TYPE}" == "+" ]
  then
    cat ${DIFF_FILE} | grep "^+ " | grep -v "\"username\": \".*\""  |  wc -l 
  else
    cat ${DIFF_FILE} | grep "^- " | grep -v "\"username\": \".*\"" | wc -l     
  fi
}

################################
echo "prepare app"
if [ -d app ]
then
  rm -rf app
fi

git init app

if [ -d app -a -d app/.git ]
then
  cd app
else
 echo "create app git repo failed!"
  exit 1
fi

MSG="export app json"
showlog 1 "$MSG"
mongoexport -h 127.0.0.1 --port 8290 -d forge -c app --jsonArray -o app.json -q '{state:{$not:{$in:["Terminated"]}}}'

#app.json is single line，app-fmt.json is multiple lines
MSG="json pretty"
showlog 2 "$MSG"
cat app.json |  python -mjson.tool > app-fmt.json
add2git "$MSG"

echo
echo "Test"
echo -e " @{ \n {@ \n .} \n }.\n" | grep -E "@\{|\{@|\.\}|\}\."
echo "------------------------------"
echo "check '@{'    '{@'    '.}'    '}.'"
grep -E "@\{|\{@|\.\}|\}\."  app-fmt.json
echo

MSG="[sed]replace '@uuid.' to '{@uuid.}'"
showlog 3 "$MSG"
sed -i -e "s/@[A-Z 0-9]\{8\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{12\}\./\{&\}/g" app-fmt.json
add2git "$MSG"

NREF_BEFORE=`sed -n '/@[A-Z 0-9]\{8\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{12\}\./p' app-fmt.json | wc -l`


MSG="[sed]replace '{@' to '@{'"
showlog 4 "$MSG"
sed -i -e "s/{@/@\{/g" app-fmt.json
add2git "$MSG"

MSG="[sed]replace '.}' to '}.'"
showlog 5 "$MSG"
sed -i -e "s/\.}/\}\./g" app-fmt.json
add2git "$MSG"


MSG="[sed]for test, username set to 'eGppbW15'"
showlog '{tmp}' "$MSG"
sed  -i  "/\"username\": \".*\",/c \"username\": \"eGppbW15\"," app-fmt.json 
add2git "$MSG"

NREF_AFTER=`sed -n '/@{[A-Z 0-9]\{8\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{4\}-[A-Z 0-9]\{12\}}\./p' app-fmt.json | wc -l`

 

echo -e "\n-----------------------------------------------------"

echo -e "\n--------------------------------------\ngenerate diff"
git diff HEAD~4..HEAD > diff.log

echo -e "\n--------------------------------------\ngenerate change"
#cat diff.log| awk '/^+/{print $0 }/^-/{print $0}' > changed.log
cat diff.log| awk '/^+/{printf "%s\n", $0 ;getline; if(substr($0,1,1)!="+"){print ""}else{print $0} }/^-/{print $0}' > changed.log

echo -e "\n--------------------------------------\ncheck changed line\n"
checkdiff "diff.log" -
checkdiff "diff.log" +
checkdiff "changed.log" -
checkdiff "changed.log" +

echo -e "\n---------------------------------------------------------\n"
echo ">ref_before : " ${NREF_BEFORE}
echo ">ref_after : " ${NREF_AFTER}

echo -e "\n==========================================="
echo -e "\n**please use 'vim app/changed.log' to verify**"
echo -e "\nupdate mongo data  'mongoimport -h 127.0.0.1 --port 8290 -d forge -c app --jsonArray --file app-fmt.json --upsert'"
echo -e "\ndone\n"
