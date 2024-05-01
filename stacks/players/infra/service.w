bring cloud;
bring tsoa;
bring postgres;
bring "../../teams/infra/service.w" as t;
bring "../../storage/infra/service.w" as s;

pub struct ServiceProps {
  teams: t.IService;
  storage: s.IService;
}
pub class Service {
  pub postgres: postgres.Database;
  pub url: str;
  new(props: ServiceProps) {

    this.postgres = new postgres.Database(name: "test", pgVersion: 15) as "Postgres";
    let api = new tsoa.Service(
      controllerPathGlobs: ["../controllers/*.ts"],
      outputDirectory: "../build",
      routesDir: "../build",
      watchDir: "../controllers/"
    ) as "TSOA";
    // TODO, maybe this should be something else then calling new on the external service

    this.url = api.url;
    api.lift(this.postgres, id: "db", allow: ["query"]);
    api.lift(unsafeCast(props.teams), id: "getTeamByPlayerName", allow: ["invoke"]);
    api.lift(props.storage.bucket(), id: "images", allow: ["put"]);

    let createTable = new cloud.OnDeploy(inflight () => {
    this.postgres.query("CREATE TABLE IF NOT EXISTS players (
      id serial PRIMARY KEY,
      name VARCHAR ( 50 ) NOT NULL,
      team VARCHAR ( 50 ) NOT NULL);");
    });
    nodeof(createTable).hidden = true;

  }
}






