bring cloud;
bring "../../../common/acme.w" as acme;

pub class Service extends acme.Service {
  pub blobStorage: cloud.Bucket;
  new() {
    super("storage");
    this.blobStorage = this.newBucket();
  }
}






