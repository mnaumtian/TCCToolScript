set -x
set -e

apt-get update
apt -y install ssh
apt -y install sshpass

ssh-keygen -R %target_hostname%
sshpass -p %TargetPass% 
ssh -o StrictHostKeyChecking=no root@%target_hostname% 'uname -a'

set -e
set -x

rm -rf %extract_dir%
mkdir -p %extract_dir%

cd %extract_dir%
tar -xvf %dep.TCCsdk_Mainline_Build_CreateHostPackage.output_dir%/%dep.TCCsdk_Mainline_Build_CreateHostPackage.host_archive_name% -C .

set -x
set -e

rm -rf %host_test_path%
mkdir %host_test_path%

cp %tccdev_checkout_dir%/ci/run_robot_tests.py %host_test_path%
cp %arch_tests_dir%/tcc_tools_tests.tar.gz %host_test_path%

cd %host_test_path%
tar -xzf tcc_tools_tests.tar.gz
set -x

rm -rf %target_download_dir%
Test

%tcc_tools_root%/target => target
%tccdev_checkout_dir%/ci/check_tcc_uninstall.sh


set -x
set -e
set -x

cd %target_download_dir%

# Remove all TCC Tools files (ignore possible non-zero code)
./check_tcc_uninstall.sh -d || true

cd target
./tcc_setup.py -i %product_name%_target_*.tar.gz


%target_hostname%:%target_download_dir%

%arch_tests_dir%/tcc_tools_tests.tar.gz

%tccdev_checkout_dir%/ci/run_robot_tests.py
%tccdev_checkout_dir%/ci/run_platform_tests.py
%tccdev_checkout_dir%/ci/remove_tcc_files.sh


%target_hostname%

set -e

cd %target_download_dir%
tar -xzf tcc_tools_tests.tar.gz

set -x


if [ %BIOS_TYPE% == "UEFI" ]; then
script="/usr/share/tcc_tools/scripts/setup_ssram/tcc_setup_ssram.sh"
else
script="%target_download_dir%/install/tests/util/setup_ssram_sbl/tcc_setup_ssram_sbl.sh"
fi

if [ %WORKFLOW% = "DAILY" ]; then
 # Force enable cache lock in daily, because cache agents bit masks aren't checked know, because
 # hypervisor changes L2 and L3
 bash "$script" enable
fi

bash "$script" enable --verify
if [ $? -ne 0 ]; then
 bash "$script" enable
fi

set -x

TIMEOUT_SEC=10
ATTEMPTS=15

ssh-keygen -R %target_hostname%
for i in `seq 1 $ATTEMPTS`; do
 # -o ConnectTimeout=$TIMEOUT_SEC doesn't work for Team City
 sshpass -p %TargetPass% ssh -o StrictHostKeyChecking=no -q root@%target_hostname% exit
 if [ $? -eq 0 ]; then
 exit 0
 fi
 sleep $TIMEOUT_SEC
done
exit -1


set -e
set -x
set -e

if [ %BIOS_TYPE% == "UEFI" ]; then
script="/usr/share/tcc_tools/scripts/setup_ssram/tcc_setup_ssram.sh"
else
script="%target_download_dir%/install/tests/util/setup_ssram_sbl/tcc_setup_ssram_sbl.sh"
fi

bash "$script" enable --verify


#!/bin/bash

sshpass -p %TargetPass% ssh -o StrictHostKeyChecking=no -q root@%target_hostname% date +%%Y%%m%%d -s $(date +%%Y%%m%%d)
sshpass -p %TargetPass% ssh -o StrictHostKeyChecking=no -q root@%target_hostname% date +%%T -s $(date +%%T)


#!/usr/bin/env bash

set -x
set -e

# Setup target properties
export TARGET_HOSTNAME=%target_hostname%
export TARGET_PORT=22
export TARGET_USERNAME=root
export TARGET_PASSWORD=%TargetPass%
export TEST_TYPE=%TEST_TYPE%

# Source env
source %path_to_vars%/vars.sh

# Convert to lower case
WORKFLOW=$(echo %WORKFLOW% | tr '[:upper:]' '[:lower:]')
PLATFORM_NAME=$(echo %PLATFORM_NAME% | tr '[:upper:]' '[:lower:]')
TEST_TYPE=$(echo %TEST_TYPE% | tr '[:upper:]' '[:lower:]')

cd %host_test_path%

export BASIC_PATH=$(pwd)
export PATH=${PATH}:${BASIC_PATH}/install/tests/robotframework/src/bin
export PYTHONPATH=${BASIC_PATH}/install/tests/robotframework/src:${PYTHONPATH+:${PYTHONPATH}}
export BIOS_TYPE=%BIOS_TYPE%
echo Bios type set as $BIOS_TYPE

./run_robot_tests.py\
 -A "${BASIC_PATH}/install/tests/argument_files/${PLATFORM_NAME}/argumentfile_$WORKFLOW.txt" \
 --tests_list "${BASIC_PATH}/install/tests/tests_lists/${PLATFORM_NAME}/${TEST_TYPE}/tests_list_robot_$WORKFLOW.txt" \
 --skip %EXCLUDE_TAGS%


 %target_hostname%

set -e
set -x

cd ~/.tcc_tools
./tcc_setup.py -u -f

%target_hostname%

%target_download_dir%/check_tcc_uninstall.sh -d


import os, platform

indent_string = " "

def print_log(message, indent_level=0):
 print(indent_level * indent_string + message)
 pass

print_log('Teamcity branch: ' + '%teamcity.build.branch%')
if '/' in '%teamcity.build.branch%' :
 print('%teamcity.build.branch%'.split('/',2))
 branch_name = '%teamcity.build.branch%'.split('/',2)[-1]
 print(branch_name)
 branch_name = branch_name.replace('/','-')
 print(branch_name)
else:
 branch_name = '%teamcity.build.branch%'

output_dir = R"""%output_dir_to_change%"""
output_dir_win = R"""%output_dir_win_to_change%"""
build_number = '%build.number%'

branch_name_number = R"%s_%s" % (branch_name, build_number)
output_dir_branch = R"%s/%s" % (output_dir, branch_name_number)
output_dir_win_branch = R"%s\%s" % (output_dir_win, branch_name_number)
print_log('Output linux directory: ' + output_dir_branch)
print_log('Output windows directory: ' + output_dir_win_branch)

print_log('Setting teamcity parameters')
print ("##teamcity[setParameter name='output_dir' value='%s']" % (output_dir_branch,))
print ("##teamcity[setParameter name='output_dir_win' value='%s']" % (output_dir_win_branch,))
print ("##teamcity[setParameter name='branch_dir' value='%s']" % (branch_name_number,))

print_log('Your build platform is ' + platform.system())
if (platform.system() == 'Linux' ):
 dir_name = output_dir_branch
elif (platform.system() == 'Windows' ):
 dir_name =output_dir_win_branch
else:
 print ("Unknown os")
 exit(-1)
print_log('Creating folder: ' + dir_name)
if not os.path.exists(dir_name):
 os.makedirs(dir_name)



 set -x
set -e

# Copy robot results
rm -rf robot_result
cp -r %host_test_path%/robot_result .

# Merge results
rm -rf robot_summary
mkdir robot_summary

for dir in \
robot_result/dso_logs
do
 if [ -d "$dir" ]
 then
 cp -r $dir robot_summary
 fi
done

rebot --nostatusrc -N %PLATFORM_NAME%_summary -d robot_summary -l %PLATFORM_NAME%_summary_log.html\
 -r %PLATFORM_NAME%_summary_report.html -x %PLATFORM_NAME%_summary_xoutput.xml -o %PLATFORM_NAME%_summary_output.xml\
 robot_result/*_output.xml

# Copy to share
cp -r robot_result %output_dir%
cp -r robot_summary %output_dir%