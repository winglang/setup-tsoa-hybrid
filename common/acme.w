bring cloud;
bring util;
bring aws;
bring "cdktf" as cdktf;

struct Params {
  getTeamByPlayerNameArn: str?;
  imagesBucketName: str?;
}


pub class Service {
  pub name: str;
  params: Params;
  new(name: str) {
    this.name = name;
    this.params = Params.fromJson(nodeof(this).app.parameters.read(schema: Params.schema()));
    if this.isServiceUnderDev() {
      nodeof(this).title = name;
    } else {
      nodeof(this).title = "AWS:{name}";
    }
  }
  isServiceUnderDev():bool {
    return util.env("SYSTEM_UNDER_DEV") == this.name || util.env("SYSTEM_UNDER_DEV") == "ALL_DEV" ;
  }
  pub newBucket(props: cloud.BucketProps?): cloud.Bucket {
    if util.env("WING_TARGET") == "tf-aws" {
      let b = new cloud.Bucket(); 
      new cdktf.TerraformOutput(value: aws.Bucket.from(b)?.bucketName);
      return b;
    }  
    if this.isServiceUnderDev() {
      return new cloud.Bucket(props);
    } else {
      return unsafeCast(new aws.BucketRef(this.params.imagesBucketName!));

    }
  }
  pub newFunction(fn: inflight (str?): str?, props: cloud.FunctionProps?): cloud.Function {
    if util.env("WING_TARGET") == "tf-aws" {
      let f = new cloud.Function(fn, props) as this.name + "_func"; 
      new cdktf.TerraformOutput(value: aws.Function.from(f)?.functionArn) as this.node.id + "_output" ;
      return f;
    } 
    if this.isServiceUnderDev() {
      let f = new cloud.Function(fn, props) as this.name + "_func"; 
      return f;
    } else {
      return unsafeCast(new aws.FunctionRef(this.params.getTeamByPlayerNameArn!));
    }  
    
  }
}

  // pub class Function {
  //   inner: cloud.Function;
  //   new(fn: inflight (str?): str?, props: cloud.FunctionProps?) {
  //     // TODO add ref
  //     log(this.node.id);
  //     log(this.node.addr);
  //     log(this.node.path);
  //     this.inner = new cloud.Function(fn, props);
  //     if util.env("WING_TARGET") == "tf-aws" {
  //       new cdktf.TerraformOutput(value: aws.Function.from(this.inner)?.functionArn) as this.node.id + "_output" ;
  //     }
  //   }

  //   pub inflight invoke(m: str?): str? {
  //     return this.inner.invoke(m);
  //   }
  // }