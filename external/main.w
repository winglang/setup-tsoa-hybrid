bring cloud;
bring aws;
bring "cdktf" as cdktf;

let bucket = new cloud.Bucket() as "tsoa-setup-remote-bucket";

let getTeamByPlayerName = new cloud.Function(inflight (payload) => {
  if let name = payload {
    if name.length % 2 == 0 {
      return "FC Haifa";
    } else {
      return "FC TLV";
    }
  } else {
    return "Unknown Team";
  }
}) as "tsoa-setup-remote-function";

new cdktf.TerraformOutput(value: aws.Function.from(getTeamByPlayerName)?.functionArn) as "getTeamByPlayerNameArn" ;
new cdktf.TerraformOutput(value: aws.Bucket.from(bucket)?.bucketName) as "imagesBucketName";
