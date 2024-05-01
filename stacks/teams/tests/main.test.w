bring "../infra/service.w" as service;
bring expect; 
bring util;

let teams = new service.Service();
test "Eyal is in Haifa" {
  let team = teams.invoke("Eyal");
  expect.equal(team, "FC Haifa");
}

test "Nimni is in TLV" {
  let team = teams.invoke("Nimni");
  expect.equal(team, "FC TLV");
}