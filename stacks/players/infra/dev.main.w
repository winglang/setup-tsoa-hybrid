bring "./lib.w" as lib;
bring http;
bring expect;

let players = new lib.Players();

test "get players as function invoke" {
  let res = Json.parse(players.function.invoke(
    Json.stringify({
      method: "GET",
      path: "/players",
    })
  ) ?? "");
  log("{res}");
  expect.equal(res["status"], 200);
}

test "create a player with team" {
  let res = http.post("{players.url}/players", {
    body: Json.stringify({
      name: "Red Orbach",
      team: "Red Team",
    }),
  });
  let id = res.body;
  let player = Json.parse(http.get("{players.url}/players/{id}").body);
  log("{player}");
  expect.equal(res.status, 201);
  expect.equal("Red Orbach", player["name"].asStr());
  expect.equal("Red Team", player["team"].asStr());
}


test "create a player without team uses external service" {
  let res = http.post("{players.url}/players", {
    body: Json.stringify({ name: "Eyal" }),
  });
  expect.equal(res.status, 201);
  let id = res.body;
  let player = Json.parse(http.get("{players.url}/players/{id}").body);
  expect.equal("Eyal", player["name"].asStr());
  expect.equal("Eyal", player["team"].asStr());
}