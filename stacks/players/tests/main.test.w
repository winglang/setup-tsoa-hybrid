bring "../infra/service.w" as service;
bring expect; 
bring util;
bring http;

let players = new service.Service();

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