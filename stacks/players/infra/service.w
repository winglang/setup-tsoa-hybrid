bring cloud;
bring tsoa;
bring postgres;
bring "../../../common/acme.w" as acme;
bring "../../teams/infra/service.w" as t;
bring "../../storage/infra/service.w" as s;

pub class Service extends acme.Service {
  pub postgres: postgres.Database;
  pub url: str;
  new() {
    super("players");
    this.postgres = new postgres.Database(name: "test", pgVersion: 15) as "Postgres";
    let api = new tsoa.Service(
      controllerPathGlobs: ["../controllers/*.ts"],
      outputDirectory: "../build",
      routesDir: "../build",
      watchDir: "../controllers/"
    ) as "TSOA";
    // TODO, maybe this should be something else then calling new on the external service
    let teams =  new t.Service() as "teams"; 
    let storage = new s.Service() as "storage";
    this.url = api.url;
    api.lift(this.postgres, id: "db", allow: ["query"]);
    api.lift(teams.getTeam, id: "getTeamByPlayerName", allow: ["invoke"]);
    api.lift(storage.blobStorage, id: "images", allow: ["put"]);

    let createTable = new cloud.OnDeploy(inflight () => {
    this.postgres.query("CREATE TABLE IF NOT EXISTS players (
      id serial PRIMARY KEY,
      name VARCHAR ( 50 ) NOT NULL,
      team VARCHAR ( 50 ) NOT NULL);");
    });
    nodeof(createTable).hidden = true;

  }
}






