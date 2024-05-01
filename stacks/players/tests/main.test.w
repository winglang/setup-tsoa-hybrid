bring "../infra/service.w" as service;
bring "../../teams/infra" as teams;
bring "../../storage/infra" as storage;
bring expect; 
bring util;
bring http;

let players = new service.Service(
  teams: new teams.ServiceRef("arn:aws:lambda:us-east-1:320736226858:function:tsoa-setup-remote-function-c86c8d5f") as "teams REF",
  storage: new storage.ServiceRef("tsoa-setup-remote-bucket-c894c553-20240416144453173300000002") as "storage REF"
);


test "create a player with team" {
  let res = http.post("{players.url}/players", {
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
  let player = Json.parse(http.get("{players.url}/players/{id}").body);
  expect.equal("Red Orbach", player["name"].asStr());
  expect.equal("Red Team", player["team"].asStr());
}


test "create a player without team uses external service" {
  let res = http.post("{players.url}/players", {
    body: Json.stringify({
      name: "Eyal"
    }),
    headers: {
      "Content-Type": "application/json",
    },
  });
  expect.equal(res.status, 201);
  let id = res.body;
  let player = Json.parse(http.get("{players.url}/players/{id}").body);
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