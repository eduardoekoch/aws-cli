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
