bring cloud;
bring tsoa;
bring aws;
bring util;
bring http;
bring expect;
bring postgres;
bring simtools;
// a1 = "arn:aws:lambda:us-east-1:320736226858:function:tsoa-setup-remote-function-c86c8d5f"
// a2 = "tsoa-setup-remote-bucket-c894c553-20240416144453173300000002.s3.amazonaws.com"

struct Params {
  getTeamByPlayerNameArn: str?;
  imagesBucketName: str?;
}


let db = new postgres.Database(name: "test", pgVersion: 15);
new cloud.OnDeploy(inflight () => {
  db.query("CREATE TABLE IF NOT EXISTS players (
    id serial PRIMARY KEY,
    name VARCHAR ( 50 ) NOT NULL,
    team VARCHAR ( 50 ) NOT NULL
  );");
});

simtools.addMacro(db, "dump", inflight () => {
  log(Json.stringify(db.query("SELECT * FROM players"), indent: 1));
});

let service = new tsoa.Service(
  controllerPathGlobs: ["./controllers/*.ts"],
  outputDirectory: "../build",
  routesDir: "../build" 
);

service.lift(db, id: "db", allow: ["query"]);

simtools.addMacro(service, "add user", inflight () => {
  http.post("{service.url}/players", {
    body: Json.stringify({
      name: "John Doe",
      team: "Red Team",
    }),
    headers: {
      "Content-Type": "application/json",
    },
  });
});

// get the function ARN after deploying it
let params = Params.fromJson(nodeof(this).app.parameters.read(schema: Params.schema()));
if let arn = params.getTeamByPlayerNameArn {
  let getTeamByPlayerName = new aws.FunctionRef(arn) as "getTeamByPlayerName";
  service.lift(getTeamByPlayerName, id: "getTeamByPlayerName", allow: ["invoke"]);
}
if let bucketName = params.imagesBucketName {
  let bucket = new aws.BucketRef(bucketName) as "imagesBucket";
  service.lift(bucket, id: "bucket", allow: ["put"]);
}

test "can create and retrieve a player" {
  let res = http.post("{service.url}/players", {
    body: Json.stringify({
      name: "John Doe",
      team: "Red Team",
    }),
    headers: {
      "Content-Type": "application/json",
    },
  });
  expect.equal(res.status, 201);
  expect.equal(res.body, "1");

  let players = db.query("SELECT * FROM players");
  expect.equal(players.length, 1);
  for player in players {
    let playerFromHttp = Json.parse(http.get("{service.url}/players/{player.get("id").asNum()}").body);
    expect.equal(player.get("name"), "John Doe");
    expect.equal(playerFromHttp.get("name"), "John Doe");
  }
}


