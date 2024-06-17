bring cloud;
bring postgres;
bring util;
bring fs;
bring aws;
bring "../../../tsoa" as tsoa;
bring "../../teams/infra" as t;
bring "../../storage/infra" as s;
bring "../../../shared" as shared;

pub class Players extends shared.Stack {
  pub function: cloud.Function;
  pub url: str;

  new() {
    super("players", @dirname);

    if this.external {
      let functionArn = nodeof(this).app.parameters.read()["players"]["functionArn"].asStr();
      let url = nodeof(this).app.parameters.read()["players"]["url"].asStr();

      this.function = unsafeCast(new aws.FunctionRef(functionArn));
      this.url = url;
    } else {
      // External Deps
      let storage = new s.Storage() in nodeof(this).root;
      let teams = new t.Teams() in nodeof(this).root;

      let api = new tsoa.Service(
        controllers: [fs.join(@dirname, "../controllers/*.ts")],
      );
      this.url = api.url;
      this.function = api.function;

      api.lift(obj: teams.function, id: "teams", ops: ["invoke"]);
      api.lift(obj: storage.bucket, id: "images", ops: ["put"]);
      api.lift(obj: storage.db, id: "db", ops: ["query"]);
    }
  }
}