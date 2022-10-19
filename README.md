# SingleLog

The last logging solution you'll ever need

SingleLog is a combination of vector.dev, AWS S3 and SingleStore for consuming, storing and searching logs in a cost effective manner.


### Validate

[Inspec](https://www.inspec.com/) is used to validate that the webserver and singlstore instance are running as expected after running Terraform

### Cost

[Infracost](https://www.infracost.io/) is used to estimate the costs of this project.

Assumes 1 TB of data stored in s3, standard tier with a lot of requests.

> infracost breakdown --path . --show-skipped  --usage-file infracost-usage.yml

```
Project: gordonmurray/singlelog

 Name                                                        Monthly Qty  Unit                    Monthly Cost 
                                                                                                               
 aws_instance.nginx                                                                                            
 ├─ Instance usage (Linux/UNIX, on-demand, t4g.micro)                730  hours                          $6.72 
 └─ root_block_device                                                                                          
    └─ Storage (general purpose SSD, gp2)                             10  GB                             $1.10 
                                                                                                               
 aws_instance.singlestore                                                                                      
 ├─ Instance usage (Linux/UNIX, on-demand, t3.xlarge)                730  hours                        $133.15 
 └─ root_block_device                                                                                          
    └─ Storage (general purpose SSD, gp3)                            100  GB                             $8.80 
                                                                                                               
 aws_kms_key.s3                                                                                                
 ├─ Customer master key                                                1  months                         $1.00 
 ├─ Requests                                           Monthly cost depends on usage: $0.03 per 10k requests   
 ├─ ECC GenerateDataKeyPair requests                   Monthly cost depends on usage: $0.10 per 10k requests   
 └─ RSA GenerateDataKeyPair requests                   Monthly cost depends on usage: $0.10 per 10k requests   
                                                                                                               
 aws_s3_bucket.logs                                                                                            
 └─ Standard                                                                                                   
    ├─ Storage                                                     1,000  GB                            $23.00 
    ├─ PUT, COPY, POST, LIST requests                                100  1k requests                    $0.50 
    ├─ GET, SELECT, and all other requests                           100  1k requests                    $0.04 
    ├─ Select data scanned                                        10,000  GB                            $20.00 
    └─ Select data returned                                       10,000  GB                             $7.00 
                                                                                                               
 OVERALL TOTAL                                                                                         $201.31 
──────────────────────────────────
20 cloud resources were detected:
∙ 4 were estimated, 3 of which include usage-based costs, see https://infracost.io/usage-file
∙ 14 were free:
  ∙ 10 x aws_security_group_rule
  ∙ 2 x aws_security_group
  ∙ 1 x aws_key_pair
  ∙ 1 x aws_s3_bucket_acl
∙ 2 are not supported yet, see https://infracost.io/requested-resources:
  ∙ 1 x aws_s3_bucket_server_side_encryption_configuration
  ∙ 1 x aws_s3_bucket_versioning
  ```


### Security

[tfsec](https://aquasecurity.github.io/tfsec) is used to secure this Terraform project

### Usage

Set your current IP address in the `my_ip_address` key in terraform.tfvars - this will allow you to SSH in to the instances if you need to.