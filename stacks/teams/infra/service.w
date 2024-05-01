bring cloud;
bring aws;

pub interface IService extends std.IResource{
  inflight invoke(payload: str):str;
}

pub class ServiceRef impl IService{
  functionRef: aws.FunctionRef;
  new(functionArn: str) {
    this.functionRef = new aws.FunctionRef(functionArn);
  }
  pub inflight invoke(payload: str):str {
    return this.functionRef.invoke(payload)!;
  }
}

pub class Service impl IService {
  team: cloud.Function;
  new() {
    this.team = new cloud.Function(inflight (payload) => {
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
  pub inflight invoke(payload: str): str {
    return this.team.invoke(payload)!;
  }
}
