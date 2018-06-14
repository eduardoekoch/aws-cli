#!/bin/bash
#
#Requirements: AWS-Cli
#

#Deletar o RDS da App do Ambiente de Staging
aws rds delete-db-instance --db-instance-identifier app-stg --skip-final-snapshot

#Aguardar que o Status seja igual a " "
status='deleting'

until [ status != 'deleting' ]
 do
  status=$aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier==`app-stg`]'.DBInstanceStatus --output text   
 done
 
#Localiza o último Snapshot
  snap=$aws rds describe-db-snapshots --region us-east-1 --snapshot-type automated --query "DBSnapshots[?DBInstanceIdentifier=='app-prd'].DBSnapshotArn" | tail -2 | head -1

#Restaura o Snapshot
  aws rds restore-db-instance-from-db-snapshot --db-instance-identifier app-stg --db-subnet-group-name subnet-sub-rds --publicly-accessible --db-snapshot-identifier arn:aws:rds:us-east-1:174928946679:snapshot:rds:app --db-instance-class db.t2.small --no-multi-az

#Localiza o ARN do RDS criado
  rds_stg=$aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier==`app-stg`].DBInstanceArn'
 
#Registra o RDS na Stack do App-Stg
  aws opsworks register-rds-db-instance --region us-east-1 --stack-id f77c5f79-c55d-48c3-b4cb-da2f6827d3a9 --rds-db-instance-arn app_stg --db-user deploy --db-password password
