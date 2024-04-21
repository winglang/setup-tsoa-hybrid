# guide-tsoa-hybrid

This repo conatins a demo showing how to use Wing to run a TSOA application which can access both local resources and cloud resources.

### Installation

`npm i`

### Testing

`wing test backend/main.w`

### Optional - Update the external resources references

Change `wing.json` to reference your external resources. E.g. the images bucket name should point to a bucket in your AWS account