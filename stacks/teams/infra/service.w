bring "../../../common/acme.w" as acme;
bring cloud;
pub class Teams extends acme.Service {
  pub getTeam: cloud.Function;
  new() {
    this.getTeam = new cloud.Function(inflight (payload) => {
      if let name = payload {
        if name.length % 2 == 0 {
          return "FC Haifa";
        } else {
          return "FC TLV";
        }
      } else {
        return "Unknown Team";
      }
    });
  }
}