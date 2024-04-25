bring cloud;
bring util;
bring aws;
bring "cdktf" as cdktf;
bring "constructs" as constructs;

pub class Service {
  pub name: str;
  new(name: str) {
    this.name = name;
  }

  pub newFunction(fn: inflight (str?): str?, props: cloud.FunctionProps?): cloud.Function {
    if util.env("SYSTEM_UNDER_DEV") == this.name {
      let f = new cloud.Function(fn, props) as this.name + "_func"; 
      if util.env("WING_TARGET") == "tf-aws" {
        new cdktf.TerraformOutput(value: aws.Function.from(f)?.functionArn) as this.node.id + "_output" ;
      }
      return f;
    } else {

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