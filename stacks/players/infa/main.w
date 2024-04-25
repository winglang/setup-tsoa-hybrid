bring cloud;
bring tsoa;
bring postgres;
bring "../../external/acme-services.w" as acme;
class PlayerMicroStack extends acme.Services {
  pub queue: cloud.Queue;
  new() {
    this.queue = new cloud.Queue();

  }
}
new PlayerMicroStack();
let services = new acme.Services();
let db = new postgres.Database(name: "test", pgVersion: 15) as "RDS: Postgres";
let api = new tsoa.Service(
  controllerPathGlobs: ["../controllers/*.ts"],
  outputDirectory: "../../build",
  routesDir: "../../build",
  watchDir: "../controllers/"
);

api.lift(db, id: "db", allow: ["query"]);
api.lift(services.team(), id: "getTeamByPlayerName", allow: ["invoke"]);
api.lift(services.imagesBucket(), id: "images", allow: ["put"]);
api.lift(queue, id:"queue", allow:["push"]);



let createTable = new cloud.OnDeploy(inflight () => {
  db.query("CREATE TABLE IF NOT EXISTS players (
    id serial PRIMARY KEY,
    name VARCHAR ( 50 ) NOT NULL,
    team VARCHAR ( 50 ) NOT NULL
  );");
});
nodeof(createTable).hidden = true;



bring util;
bring http;
bring expect;

test "create a player with team" {
  let res = http.post("{api.url}/players", {
    body: Json.stringify({
      name: "Red Orbach",
      team: "Red Team",
    }),
    headers: {
      "Content-Type": "application/json",
    },
  });
  expect.equal(res.status, 201);
  let id = res.body;
  let player = Json.parse(http.get("{api.url}/players/{id}").body);
  expect.equal("Red Orbach", player["name"].asStr());
  expect.equal("Red Team", player["team"].asStr());
}


test "create a player without team uses external service" {
  let res = http.post("{api.url}/players", {
    body: Json.stringify({
      name: "Eyal"
    }),
    headers: {
      "Content-Type": "application/json",
    },
  });
  expect.equal(res.status, 201);
  let id = res.body;
  let player = Json.parse(http.get("{api.url}/players/{id}").body);
  expect.equal("Eyal", player["name"].asStr());
  expect.equal("FC Haifa", player["team"].asStr());
}

// test "When creating a new player we should get a message in the queue" {
//   let res = http.post("{api.url}/players", {
//     body: Json.stringify({
//       name: "Eyal"
//     }),
//     headers: {
//       "Content-Type": "application/json",
//     },
//   });
//   util.waitUntil(() => {
//     return queue.approxSize() > 0;
//   });
//   let actual = queue.pop()!;
//   log(actual);
//   expect.equal("1", actual);
// }