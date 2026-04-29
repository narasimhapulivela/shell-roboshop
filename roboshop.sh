#!/bin/bash

SG_ID="sg-0f489618a29abfadb"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@ 
do 
  instance_id=$( aws ec2 run-instances \
  --image-id $AMD_ID \
  --instance-type t3.micro \
  --security-group-ids $SG_ID \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output text )
  if [ $instance == "frontend" ]; then
     ip=$(
      aws ec2 describe-instances \
      --instance-ids $instance_id \
      --query 'Reservations[0].Instances[0].PublicIpAddress' \
      --output text
     )
    else
   
     ip=$(
      aws ec2 describe-instances \
      --instance-ids $instance_id \
      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
      --output text
     )
      
    fi 

    echo "ip adress:  $IP"


done




