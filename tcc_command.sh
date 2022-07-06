set -x
set -e

#target_hostname=
#extract_dir=

apt -y install openssh-client
ssh-keygen -R %target_hostname%
sshpass -p %TargetPass% ssh -o StrictHostKeyChecking=no root@%target_hostname% 'uname -a'

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