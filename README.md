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

## Workarounds, Boilerplate, and Issues

- [ ] We don't create new cloud.Function nor new acme.Function instead I am using service.newFunction
  - [ ] Also related to `SYSTEM_UNDER_DEV=$(basename $(pwd))`
- [ ] main.w is boilerplate for every service
- [ ] wing run watch doesn't work for external stuff, should it? 
- [ ] We are not DRY the service name appears both on the constructor  
- [ ] unsafeCast