#!/bin/bash

## Script to create Windows Instance and to take pull the docker image
## Once that create an AMI using it

img_id=ami-fd90a482
subnet=subnet-44544268
sec_grp=sg-62ac0628
key_name=vinay_home

echo "<script>
echo "hi" > c:/test.txt
docker run hello-world:latest
docker images >> c:/test.txt
</script>" > user_data

instn_create=$(aws ec2 run-instances --image-id $img_id --subnet-id $subnet --security-group-ids $sec_grp --count 1 --instance-type t2.micro --key-name $key_name --user-data file://user_data --query 'Instances[0].InstanceId')

act_id=$(echo $instn_create | cut -d '"' -f 2 | cut -d '"' -f 1)

sleep 2

#act_id=$(echo $instn_create | awk -F '"' '{print $2}')
#act_id=$(echo $instn_create | cut -d '"' -f 2 | cut -d '"' -f 1)
echo "############################################"
echo ""
echo "Instance is creating with id = $instn_create"
echo ""
echo "actual id - $act_id"
echo ""
echo "############################################"
#inst_state=$(aws ec2 describe-instance-status --instance-ids $act_id | grep -A4 -w "InstanceStatus" | sed -n 5p | awk '{print $2}' | awk -F '"' '{print $2}')
sleep 50
#aws ec2 describe-instance-status --instance-ids $act_id | grep -A4 -w "InstanceStatus" | sed -n 5p | awk '{print $2}' | awk -F '"' '{print $2}' > otp_desc.txt
#aws ec2 describe-instance-status --instance-ids ${act_id}
#inst_state=$(aws ec2 describe-instance-status --instance-ids $act_id | grep -A4 -w "InstanceStatus" | sed -n 5p | awk '{print $2}' | awk -F '"' '{print $2}')

#inst_state=`cat otp_desc.txt`
#echo "instate state - $inst_state"

#aws ec2 create-image --instance-id $act_id --name "test" --description "windows" --no-reboot

function_sts() {
#if [ $inst_state -eq "initializing" ]; then
#    sleep 5m
#fi

while [ $(aws ec2 describe-instance-status --instance-ids $act_id | grep -A4 -w "InstanceStatus" | sed -n 5p | awk '{print $2}' | awk -F '"' '{print $2}') != "passed" ]
do
    echo "State of instance = initializing"
    sleep 1
done

}

function_sts
echo "##################################"
echo "State of instance is now = passed"
echo ""
echo "Creating the AMI of instance now....please stand-by......"
aws ec2 create-image --instance-id $act_id --name "test" --description "windows" --no-reboot

echo "##################################"
