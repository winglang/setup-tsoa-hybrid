bring "../../../common/acme.w" as acme;
bring cloud;

pub class Service extends acme.Service {
  pub getTeam: cloud.Function;
  new() {
    super("teams");
    this.getTeam = this.newFunction(inflight (payload) => {
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