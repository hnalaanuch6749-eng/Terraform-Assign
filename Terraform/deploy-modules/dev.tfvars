############################ TF Vars for common calls ##############
product    = "myawesome"
sdlcenv    = "sbx"
accountenv = "npd"





########################### VPC TF Vars ##############################
vpc_function        = "test"
vpc_cidrblock       = "10.35.0.0/16"
private_subnet_cidr = "10.35.0.0/24"
public_subnet_cidr  = "10.35.12.0/24"
enable_nat_gateway  = true
availability_zones  = ["us-east-1a"]



########################## Lambda TF Vars #############################
lambda_functionrole  = "cwevent"
schedule_expression  = "cron(0 2 * * ? *)"
schedule_description = "Run Lambda daily at 02:00 UTC"
enabled              = true
cw_eventrulename     = "daily_schedule"



########################## SNAPSHOT Cleanup vars #######################
lambda_functionname         = "snapshot-cleanup"
days_old                    = 365
timeout                     = 300
enable_schedule             = true
schedule_expressionsnapshot = "rate(30 days)"
