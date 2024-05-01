bring cloud;
bring aws;

pub interface IService extends std.IResource {
  bucket() : cloud.Bucket;
}

pub class ServiceRef impl IService{
  bucketRef: aws.BucketRef;
  new(bucketName: str) {
    this.bucketRef = new aws.BucketRef(bucketName);
  }
  pub bucket(): cloud.Bucket {
    return unsafeCast(this.bucketRef);
  }
}


pub class Service  {
  pub blobStorage: cloud.Bucket;
  new() {
    this.blobStorage = new cloud.Bucket();
  }
  pub bucket(): cloud.Bucket {
    return unsafeCast(this.blobStorage);
  }
}






