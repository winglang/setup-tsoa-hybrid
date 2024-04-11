bring cloud;
bring tsoa;
bring aws;
bring util;
bring http;
bring expect;

struct Params {
  getTeamByPlayerIdArn: str;
}

// create a AWS function
if util.env("WING_TARGET") == "tf-aws" {
  bring "cdktf" as cdktf;
  let getTeamByPlayerId = new cloud.Function(inflight (payload) => {
    if let playerId = payload {
      if num.fromStr(playerId) % 2 == 0 {
        return "Blue Team";
      } else {
        return "Red Team";
      }
    }

    return "Green Team";
  });
  
  new cdktf.TerraformOutput(value: aws.Function.from(getTeamByPlayerId)?.functionArn);
} else {
  let playersStore = new cloud.Bucket();
  let service = new tsoa.Service(
    controllerPathGlobs: ["../src/*Controller.ts"],
    outputDirectory: "../build",
    routesDir: "../build" 
  );
  
  service.lift(playersStore, id: "playersStore", allow: ["tryGet", "put"]);

  if !nodeof(this).app.isTestEnvironment {
    // get the function ARN after deploying it
    if let arn = nodeof(this).app.parameters.read(schema: Params.schema()).tryGet("getTeamByPlayerIdArn")?.tryAsStr() {
      let getTeamByPlayerId = new aws.FunctionRef(arn) as "getTeamByPlayerId";
      service.lift(getTeamByPlayerId, id: "getTeamByPlayerId", allow: ["invoke"]);
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

    let players = playersStore.list();
    expect.equal(players.length, 1);
    for playerId in playersStore.list() {
      let player = Json.parse(http.get("{service.url}/players/{playerId}").body);
      expect.equal(player.get("name"), "John Doe");
    }
  }
}

