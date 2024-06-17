bring cloud;
bring aws;
bring postgres;
bring "../../../shared" as shared;


/// Core storage shared across several microstacks
pub class Storage extends shared.Stack {
  pub bucket: cloud.Bucket;
  pub db: postgres.Database;

  new() {
    super("storage", @dirname);
    if this.external {
      let bucketName = nodeof(this).app.parameters.read()["storage"]["bucketName"].asStr();
      this.bucket = unsafeCast(new aws.BucketRef(bucketName));
      this.db = unsafeCast(new postgres.DatabaseRef());
    } else {
      this.bucket = new cloud.Bucket();
      this.db = new postgres.Database(name: "test");
      let createTable = new cloud.OnDeploy(inflight () => {
        this.db.query("
          CREATE TABLE IF NOT EXISTS players (
          id serial PRIMARY KEY,
          name VARCHAR ( 50 ) NOT NULL,
          team VARCHAR ( 50 ) NOT NULL);");
        }
      );
      nodeof(createTable).hidden = true;
    }
  }
}