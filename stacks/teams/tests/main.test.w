bring "../infra/service.w" as service;
bring expect; 
bring util;

let teams = new service.Teams();
test "Eyal is in Haifa" {
  let team = teams.getTeam.invoke("Eyal");
  expect.equal(team, "FC Haifa");
}

test "Nimni is in TLV" {
  let team = teams.getTeam.invoke("Nimni");
  expect.equal(team, "FC TLV");
}