# multi-cloud-deployer

## This is a sample application to exemplify multi-cloud deployment using terraform to orquestrate infrastructure creation accross public cloud vendors (e.g. AWS and Azure)

The goal is to show how to automate describe basic infrastrucutre creation using only one tool and pattern

## Setup

For running this sample application, you will need both AWS and Azure valid accounts. If you already have both, you're good to go, otherwise, visit <https://aws.amazon.com/free/> & <https://azure.microsoft.com/en-us/free/>

The next step is to obtain valid credentials so we can automate our infrastructure creation. In order to do that, create valid keys for AWS and Azure as described bellow and them source them to your bash context.

* AWS > <http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html> 
* Azure > <https://www.packer.io/docs/builders/azure-setup.html> *This one was harder to figure out. Best documentation I found was from Hashicorp

After clonning this repository, go to the root of this project and create the following file:
`vim env-var.sh`

Replace the keys bellow with the information you got from the previous steps

```
#! /bin/bash
export ARM_SUBSCRIPTION_ID=XXXXXXXXX
export ARM_CLIENT_ID=XXXXXXXXX
export ARM_CLIENT_SECRET=XXXXXXXXX
export ARM_TENANT_ID=XXXXXXXXX
export ARM_ENVIRONMENT=public
export AWS_ACCESS_KEY_ID=XXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXX
export AWS_DEFAULT_REGION=sa-east-1
```
Them, source them to your bash context `source env-var.sh`

Once your credentials are valid, you're gonna need to install the dependencies, in case you haven't them installed yet

* AWS Cli > <http://docs.aws.amazon.com/cli/latest/userguide/installing.html>
* Terraform > <https://www.terraform.io/downloads.html> *Make sure you add the binary to your PATH

Finally, run `aws configure` and insert your access key and secret key from AWS. This will be necessary to create and access the terraform remote state, located on AWS's S3. *If you get error regarding the bucket name, replace them to whatever name you want and make sure you replace in the provider informations as well, located on `terraform/aws/provider.tf` and `terraform/azure/provider.tf`

```
aws s3api create-bucket --bucket terraform-state-multicloud-poc-aws
aws s3api create-bucket --bucket terraform-state-multicloud-poc-azure
```

## Deploying to AWS

The first cloud we're going to deploy our sample application is going to be AWS and for that matter, the first step we need to take is to register a domain and host it's DNS records using Route 53. * In case you already have a domain on Route 53, it's fine to use it.

* How to register a domain in Route 53 > <http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html>

The next step is to replace our sample domain "cloud104.io" to your registered domain. Make sure you find and replace both on `terraform/aws/deploy.tf` and `terraform/azure/deploy.tf`. It should look like this:
```
data "aws_route53_zone" "services_public_zone" {
  name = "mydomain.com."
}
```
Now that everything is set up, you should be good to go and try your first deploy. To do so, navigate do `terraform/aws`and run `terraform init`, `terraform plan` and `terraform apply`
```
➜  multi-cloud-deployer git:(master) ✗ cd terraform/aws 
➜  aws git:(master) ✗ 
➜  aws git:(master) ✗ terraform init
Initializing the backend...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your environment. If you forget, other
commands will detect it and remind you to do so if necessary.

➜  aws git:(master) ✗ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.aws_route53_zone.services_public_zone: Refreshing state...
The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

.....

➜  aws git:(master) ✗ terraform apply
data.aws_route53_zone.services_public_zone: Refreshing state...
aws_vpc.vpc_test: Creating...

.....

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

```

Wait a few moments for the virtual machine be up and running and check your domain (e.g. <http://multi-cloud.cloud104.io>). If you get the following screen, congratulations! You just deployed your sample application using some piece of nice automation :)

![aws](https://raw.githubusercontent.com/panazzo/multi-cloud-deployer/master/site/img/aws.jpg)

## Deploying to Azure

The next step of our sample multi-cloud deployment is to deploy to another public cloud vendor, in this case, Azure. By this time, if you've completed all the previous set up steps, you shouldn't have any more set ups to do, so seat back, relax and enjoy your application being provisioned automaticaly following these next steps:

Navigate do `terraform/azure`and run `terraform init`, `terraform plan` and `terraform apply`. The output might be like this:

```
➜  azure git:(master) terraform init
Initializing the backend...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your environment. If you forget, other
commands will detect it and remind you to do so if necessary.

➜  azure git:(master) terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

.....

➜  azure git:(master) terraform apply
data.aws_route53_zone.services_public_zone: Refreshing state...
azurerm_resource_group.resource_group_test: Creating...

.....

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

```

If you're lucky enought to made trought here, you should get the following screen when you hit your sample application url:

![azure](https://raw.githubusercontent.com/panazzo/multi-cloud-deployer/master/site/img/azure.jpg)

Now, everytime you wish change your public cloud vendor, just go to `terraform/<vendor>` and run `terraform apply``

#CodeOn :D