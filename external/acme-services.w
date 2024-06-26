bring aws;

struct Params {
  getTeamByPlayerNameArn: str?;
  imagesBucketName: str?;
}

pub class Services {
  params: Params;
  new (){
    this.params = Params.fromJson(nodeof(this).app.parameters.read(schema: Params.schema()));
    nodeof(this).title = "ACME Services";
  }

  pub team(): aws.FunctionRef {
    return new aws.FunctionRef(this.params.getTeamByPlayerNameArn!) as "getTeamByPlayerName";
  }

  pub imagesBucket(): aws.BucketRef {
    return new aws.BucketRef(this.params.imagesBucketName!) as "imagesBucket";
  }
}

