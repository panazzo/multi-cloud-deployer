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

## Deploying to Azure