# guide-tsoa-hybrid

This repo conatins a demo showing how to use Wing to run a TSOA application which can access both local resources and cloud resources.

### Installation

`npm i`

### Testing

`wing test backend/main.w`

### Optional - Deploy the external resources

If you want to interact with the external cloud resources, run:

```sh
wing compile -t tf-aws external/main.w
cd external/target/main.tfaws
terraform init
terraform apply
```

Note the terraform outputs are printed after the deployment is done. Copy those values to `wing.json` to interact with those resouces.