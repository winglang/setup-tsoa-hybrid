import {
  Body,
  Controller,
  Get,
  Path,
  Post,
  Route,
  SuccessResponse,
} from "tsoa";

import { S3Client , PutObjectCommand} from "@aws-sdk/client-s3"
import { lifted } from "@winglibs/tsoa/clients.js"

import { IFunctionClient, IBucketClient } from "@winglang/sdk/lib/cloud";
// import fetch from 'node-fetch';
import fs from 'fs';

// let s3client = new S3Client();

async function downloadImage(id: string) {
  let res = await fetch("https://randomuser.me/api/", { headers: {
    "Content-Type": "application/json"
  }});
  let data :any  = await res.json();
  let image = data.results[0].picture.large;
  const response = await fetch(image);
  const arrayBuffer = await response.arrayBuffer();
  let b: IBucketClient = lifted("images"); 
  
  await b.put(`images/${id}.jpg`,Buffer.from(arrayBuffer).toString("base64").replace(/^data:image\/\w+;base64,/, ""), { contentType: "image/jpeg" });
}

// Usage
export interface Player {
  id: string;
  team: string;
  name: string;
}

export interface PlayerCreationParams {
  team?: string;
  name: string;
}

@Route("players")
export class PlayersController extends Controller {
  
  @Get("/")
  public async getUsers(
  ): Promise<Player[]> {
    const db = lifted("db");
    const res = await db.query(`SELECT * FROM players`);
    return res;
  }

  @Get("{playerId}")
  public async getUser(
    @Path() playerId: string
  ): Promise<Player | undefined> {
    const db = lifted("db");
    const res = await db.query(`
      SELECT * FROM players WHERE id = ${playerId};
    `);
    if (res.length === 0) {
      this.setStatus(404);
      return;
    }
    return res[0];
  }

  @SuccessResponse("201", "Created")
  @Post()
  public async createUser(
    @Body() requestBody: PlayerCreationParams
  ): Promise<number> {
    this.setStatus(201);
    const name = requestBody.name;
    let team = requestBody.team;
    if (!team) {
      const getTeamByPlayerName: IFunctionClient = lifted("getTeamByPlayerName");
      team = await getTeamByPlayerName.invoke(name) as string;
    }
    const db = lifted("db");
    const res = await db.query(`
      INSERT INTO players (name, team) 
      VALUES ('${name}', '${team}')
      RETURNING id;`
    );
    await downloadImage(res[0].id);
    return res[0].id;
  }
}
