bring cloud;
bring tsoa;
bring postgres;
bring "../../../common/acme.w" as acme;
bring "../../teams/infra/service.w" as teams;

pub class Service extends acme.Service {
  pub queue: cloud.Queue;
  pub postgres: postgres.Database;
  pub url: str;
  new() {
    this.queue = new cloud.Queue();
    this.postgres = new postgres.Database(name: "test", pgVersion: 15) as "Postgres";
    let api = new tsoa.Service(
      controllerPathGlobs: ["../controllers/*.ts"],
      outputDirectory: "../../build",
      routesDir: "../../build",
      watchDir: "../controllers/"
    ) as "TSOA";
    this.url = api.url;
    api.lift(this.postgres, id: "db", allow: ["query"]);
    api.lift(this.queue, id:"queue", allow:["push"]);
    api.lift(new teams.Service(), id: "getTeamByPlayerName", allow: ["invoke"]);
    // api.lift(services.imagesBucket(), id: "images", allow: ["put"]);

    let createTable = new cloud.OnDeploy(inflight () => {
    this.postgres.query("CREATE TABLE IF NOT EXISTS players (
      id serial PRIMARY KEY,
      name VARCHAR ( 50 ) NOT NULL,
      team VARCHAR ( 50 ) NOT NULL);");
    });
    nodeof(createTable).hidden = true;

  }
}






