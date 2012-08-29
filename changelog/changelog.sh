#!/bin/sh
CHANGELOGSH_VERSION=0.0.1
CHANGELOGSH_AUTHOR="Hu Liupeng <liupeng.hu@gmail.com>"

# configuration
if [ -z ${CHANGELOG_FILE} ]; then
	CHANGELOG_FILE="changelog.txt"
fi
if [ -z ${CHANGELOG_EDITOR} ]; then
	CHANGELOG_EDITOR="vi"
fi
if [ -z ${CHANGELOG_EDITFILE} ]; then
	CHANGELOG_EDITFILE="CHANGELOG_EDITMSG"
fi
# template
if [ -z ${V_LABLE} ]; then
V_LABLE="version     :"
fi
if [ -z ${D_LABLE} ]; then
D_LABLE="date        :"
fi
if [ -z ${M_LABLE} ]; then
M_LABLE="md5sum      :"
fi
if [ -z ${S_LABLE} ]; then
S_LABLE="file size   :"
fi
if [ -z ${B_LABLE} ]; then
B_LABLE="bugfix      :"
fi
if [ -z ${F_LABLE} ]; then
F_LABLE="new feature :"
fi
if [ -z ${P_LABLE} ]; then
P_LABLE="platform    :"
fi
if [ -z ${N_LABLE} ]; then
N_LABLE="notes       :"
fi
if [ -z ${SEPARATOR} ]; then
SEPARATOR="--------------------------------------------------------------------------------"
fi

# usage
usage() {
cat << EOF
ChangelogSH ${CHANGELOGSH_VERSION}
Copyright (C) 2012, ${CHANGELOGSH_AUTHOR}

Usage: changelog.sh version_id version_files

Some variables can be set to change configurations of this ChangelogSH:
	variable           description
	--------------------------------------------------------------------------------
	CHANGELOG_FILE     output changelog file name, 'changelog.txt' as default.
	CHANGELOG_EDITOR   changelog file editor, 'vi' as default.
	CHANGELOG_EDITFILE temp file used to edit changelog, 'CHANGELOG_EDITMSG' as default
	V_LABLE            "version     :"
	D_LABLE            "date        :"
	M_LABLE            "md5sum      :"
	S_LABLE            "file size   :"
	B_LABLE            "bugfix      :"
	F_LABLE            "new feature :"
	P_LABLE            "platform    :"
	N_LABLE            "notes       :"
	SEPARATOR          80 '-' chars

ChangelogSH is a efficiency tool to update changelog file.

Examples:
	CHANGELOG_EDITOR="vi" ./changelog.sh 1.0.5 changelog.sh
EOF
	return 0
}

# function to check if tools are valid in the host environment
is_cmd_valid() {
	valid=1
	for i in "$@"
	do
		# 0: valid
		# 1: not valid
		valid=`$i --version 1>/dev/null 2>&1 && echo 0 || echo 1`
		if [ ${valid} -eq 1 ];then
			echo "$i not found"
			return ${valid}
		fi
	done
	return ${valid}
}

if [ $# -lt 2 ]; then
	usage
	exit 0
fi

check_version_id () {
	valid=1
	if [ $# -eq 1 ];then
		echo "$1" | grep "^[0-9]\+\.[0-9]\+\.[0-9]\+$" >/dev/null 2>&1
		return $?
	fi
	return ${valid}
}

V_ID=$1

if ! check_version_id ${V_ID}; then
	echo "version_id not valid."
	echo "abort"
	exit 1
fi

shift
V_FILE_LIST="$@"

# check gnu tools we need
if ! is_cmd_valid "date" "awk" "stat" "md5sum" "${CHANGELOG_EDITOR}"; then 
	echo "abort"
	exit 2
fi

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
	exit 3
fi

echo "changelog has been comfirmed."
echo "commit"

if [ -f ${CHANGELOG_FILE} ];then
	cat ${CHANGELOG_FILE} >> ${CHANGELOG_EDITFILE}
fi
mv ${CHANGELOG_EDITFILE} ${CHANGELOG_FILE}

