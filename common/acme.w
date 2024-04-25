bring cloud;
bring util;
bring aws;
bring "cdktf" as cdktf;
bring "constructs" as constructs;

pub class Service {

}

pub class Function {
  inner: cloud.Function;
  new(fn: inflight (str?): str?, props: cloud.FunctionProps) {
    this.inner = new cloud.Function(fn, props);
    if util.env("WING_TARGET") == "tf-aws" {
      new cdktf.TerraformOutput(value: aws.Function.from(this.inner)?.functionArn) as this.node.id + "_output" ;
    }
  }

  pub static ref(scope: constructs. IConstruct, arn: str): aws.FunctionRef {
    return new aws.FunctionRef(arn) in scope;
  }

  pub inflight invoke(m: str?): str? {
    return this.inner.invoke(m);
  }

}