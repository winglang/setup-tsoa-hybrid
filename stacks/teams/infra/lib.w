bring cloud;
bring aws;
bring fs;
bring "../../../tsoa" as tsoa;
bring "../../../shared" as shared;

pub class Teams extends shared.Stack {
  pub function: cloud.Function;
  new() {
    super("teams", @dirname);
    if this.external {
      let functionArn = nodeof(this).app.parameters.read()["teams"]["functionArn"].asStr();
      this.function = unsafeCast(new aws.FunctionRef(functionArn));
    } else {
      let service = new tsoa.Service(
        controllers: [fs.join(@dirname, "../controllers/*.ts")]
      );
      this.function = service.function;
    }
  }
}
