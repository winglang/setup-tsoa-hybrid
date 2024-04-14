bring cloud;
bring tsoa;
bring aws;
bring util;
bring http;
bring expect;
bring postgres;
bring simtools;

struct Params {
  getTeamByPlayerNameArn: str;
}

// create a AWS function
if util.env("WING_TARGET") == "tf-aws" {
  bring "cdktf" as cdktf;
  let getTeamByPlayerName = new cloud.Function(inflight (payload) => {
    if let length = payload?.length {
      if length  % 2 == 0 {
        return "Blue Team";
      } else {
        return "Red Team";
      }
    }

    return "Green Team";
  });
  
  new cdktf.TerraformOutput(value: aws.Function.from(getTeamByPlayerName)?.functionArn);
} else {
  let db = new postgres.Database(name: "test", pgVersion: 15);
  new cloud.OnDeploy(inflight () => {
    db.query("CREATE TABLE players (
      id serial PRIMARY KEY,
      name VARCHAR ( 50 ) NOT NULL,
      team VARCHAR ( 50 ) NOT NULL
    );");
  });
  simtools.addMacro(db, "dump", inflight () => {
    log(Json.stringify(db.query("SELECT * FROM players")));
  });

  let service = new tsoa.Service(
    controllerPathGlobs: ["../src/*Controller.ts"],
    outputDirectory: "../build",
    routesDir: "../build" 
  );
  
  service.lift(db, id: "db", allow: ["query"]);

  if !nodeof(this).app.isTestEnvironment {
    // get the function ARN after deploying it
    if let arn = nodeof(this).app.parameters.read(schema: Params.schema()).tryGet("getTeamByPlayerNameArn")?.tryAsStr() {
      let getTeamByPlayerName = new aws.FunctionRef(arn) as "getTeamByPlayerName";
      service.lift(getTeamByPlayerName, id: "getTeamByPlayerName", allow: ["invoke"]);
    }
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
}

