#!/bin/bash
#
#Requirements: AWS-Cli
#

#Deletar o RDS do Fin do Ambiente de Staging
aws rds delete-db-instance --db-instance-identifier fin-stg --skip-final-snapshot

#Aguardar que o Status seja igual a " "

until [ status != 'deleting' ]
 do
  status=$aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier==`fin-stg`]'.DBInstanceStatus --output text   
 done
 
#Localiza o último Snapshot
  snap=$aws rds describe-db-snapshots --region us-east-1 --snapshot-type automated --query "DBSnapshots[?DBInstanceIdentifier=='fin-prd'].DBSnapshotArn" | tail -2 | head -1

#Restaura o Snapshot
  aws rds restore-db-instance-from-db-snapshot --db-instance-identifier fin-stg --db-subnet-group-name bioritmo-sub-rds --publicly-accessible --db-snapshot-identifier arn:aws:rds:us-east-1:174928946679:snapshot:rds:fin --db-instance-class db.t2.small --no-multi-az
  
#Registra o RDS na Stack do Fin-Stg
  
