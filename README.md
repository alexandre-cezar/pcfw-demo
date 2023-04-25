# pc-demo-foundations

How to:

Each terraform file creates a specific set of the infrastructure (VPC, EC2, LB, Flow Logs, etc), so you can delete whatever parts that are not interesting to you. 

Per example, if you already have a VPC and flow logs configured or if you just don't want to create a LB service (and alerts), just delete the respective files.
 
NOTE: If you delete the VPC, keep in mind that additional adjustments are required in all the remaining files, because all the resources expect to be created in the VPC created by this code.

You will also need to set up the SSH key beforehand (creating one using terraform is possible but creates several other concerns). Just create one in AWS named pcfw-demo and copy the resulting pem file into the project folder.

There's also a need to fill the variables.tf with the proper values, where applicable.

After that, just initialize the terraform using terraform init and run it using terraform apply.

(every line in the code is documented, so if any questions arise, take a look at the code)

Final note: Some of the scripts may require adjustments, in case some level of customization is required.
