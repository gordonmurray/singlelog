# SingleLog

The last logging solution you'll ever need

SingleLog is a combination of vector.dev, AWS S3 and SingleStore for consuming, storing and searching logs in a cost effective manner.


### Validate

[Inspec](https://www.inspec.com/) is used to validate that the webserver and singlstore instance are running as expected after running Terraform

### Cost

[Infracost](https://www.infracost.io/) is used to estimate the costs of this project.

```
Project: gordonmurray/singlelog

 Name                                                       Monthly Qty  Unit                    Monthly Cost 
                                                                                                              
 aws_instance.nginx                                                                                           
 ├─ Instance usage (Linux/UNIX, on-demand, t3.micro)                730  hours                          $8.32 
 └─ root_block_device                                                                                         
    └─ Storage (general purpose SSD, gp2)                            10  GB                             $1.10 
                                                                                                              
 aws_instance.singlestore                                                                                     
 ├─ Instance usage (Linux/UNIX, on-demand, t3.micro)                730  hours                          $8.32 
 └─ root_block_device                                                                                         
    └─ Storage (general purpose SSD, gp2)                            10  GB                             $1.10 
                                                                                                              
 aws_s3_bucket.logs                                                                                           
 └─ Standard                                                                                                  
    ├─ Storage                                        Monthly cost depends on usage: $0.023 per GB            
    ├─ PUT, COPY, POST, LIST requests                 Monthly cost depends on usage: $0.005 per 1k requests   
    ├─ GET, SELECT, and all other requests            Monthly cost depends on usage: $0.0004 per 1k requests  
    ├─ Select data scanned                            Monthly cost depends on usage: $0.002 per GB            
    └─ Select data returned                           Monthly cost depends on usage: $0.0007 per GB           
                                                                                                              
 OVERALL TOTAL                                                                                         $18.84 
──────────────────────────────────
17 cloud resources were detected:
∙ 3 were estimated, all of which include usage-based costs, see https://infracost.io/usage-file
∙ 14 were free:
  ∙ 10 x aws_security_group_rule
  ∙ 2 x aws_security_group
  ∙ 1 x aws_key_pair
  ∙ 1 x aws_s3_bucket_acl
  ```


### Security

[tfsec](https://aquasecurity.github.io/tfsec) is used to secure this Terraform project