bring "./service.w" as service;
bring "../../teams/infra" as teams;
bring "../../storage/infra" as storage;

new service.Service(
  teams: new teams.ServiceRef("arn:aws:lambda:us-east-1:320736226858:function:tsoa-setup-remote-function-c86c8d5f") as "teams REF",
  storage: new storage.ServiceRef("tsoa-setup-remote-bucket-c894c553-20240416144453173300000002") as "storage REF"
);