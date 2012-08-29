#!/bin/sh

CHANGELOG_FILE="changelog.txt"

CHANGELOG_EDITOR="vi"
CHANGELOG_EDITFILE="CHANGELOG_EDITMSG"

is_cmd_valid() {
	for i in "$@"
	do
		# 0 valid
		# 1 not valid
		valid=`$i --version 1>/dev/null 2>&1 && echo 0 || echo 1`
		if [ ${valid} -eq 1 ];then
			echo "$i not found"
			return ${valid}
		fi
	done
	return ${valid}
}

if ! is_cmd_valid "date" "awk" "stat" "md5sum" "vi"; then 
	echo "abort"
	exit 0
fi

#template
V_LABLE="version     :"
D_LABLE="date        :"
M_LABLE="md5sum      :"
S_LABLE="file size   :"
B_LABLE="bugfix      :"
F_LABLE="new feature :"
P_LABLE="platform    :"
N_LABLE="notes       :"
SEPARATOR="--------------------------------------------------------------------------------"

V_FILE_LIST=""
V_FILE_LIST+=" 1.tmp"
V_FILE_LIST+=" changelog.sh"
V_ID="1.0.5"
DATE=`date +"%Y/%m/%d %H:%M:%S"`
MD5SUM=`md5sum ${V_FILE_LIST} | awk '{printf "%36s %s\n",$1,$2}'`
SIZE=`ls -l ${V_FILE_LIST} | awk '{printf "%36s %s\n",$5,$8}'`

cat << EOF > ${CHANGELOG_EDITFILE}
${V_LABLE} ${V_ID}
${D_LABLE} ${DATE}
${M_LABLE} 
${MD5SUM}
${S_LABLE}
${SIZE}
${B_LABLE}
${F_LABLE}
${P_LABLE}
${N_LABLE}
${SEPARATOR}
EOF
time1=`stat -c %Z ${CHANGELOG_EDITFILE}`
${CHANGELOG_EDITOR} ${CHANGELOG_EDITFILE}
time2=`stat -c %Z ${CHANGELOG_EDITFILE}`

#echo "${time1} -> ${time2}"
if [ ${time2} -le ${time1} ];then
	echo "changelog has not been comfirmed."
	echo "abort"
	exit 2
fi

echo "changelog has been comfirmed."
echo "commit"

if [ -f ${CHANGELOG_FILE} ];then
	cat ${CHANGELOG_FILE} >> ${CHANGELOG_EDITFILE}
fi
mv ${CHANGELOG_EDITFILE} ${CHANGELOG_FILE}

