import {
  Body,
  Controller,
  Get,
  Path,
  Post,
  Route,
  SuccessResponse,
} from "tsoa";
import { lifted } from "../../../tsoa/clients";
import type { IFunctionClient, IBucketClient } from "@winglang/sdk/lib/cloud";
import type { IDatabase$Inflight } from "@winglibs/postgres";

async function downloadImage(id: string) {
  let res = await fetch("https://randomuser.me/api/", {
    headers: {
      "Content-Type": "application/json",
    },
  });
  let data: any = await res.json();
  let image = data.results[0].picture.large;
  const response = await fetch(image);
  const arrayBuffer = await response.arrayBuffer();
  let b: IBucketClient = lifted("images");

  await b.put(
    `images/${id}.jpg`,
    Buffer.from(arrayBuffer)
      .toString("base64")
      .replace(/^data:image\/\w+;base64,/, ""),
    { contentType: "image/jpeg" }
  );
}

export interface Player {
  id: string;
  teamId: string;
  name: string;
}

export interface PlayerCreationParams {
  team?: string;
  name: string;
}

@Route("players")
export class PlayersController extends Controller {
  @Get("/")
  public async getUsers(): Promise<Player[]> {
    const db = lifted<IDatabase$Inflight>("db");
    const res = (await db.query(`SELECT * FROM players`)) as any[];

    const getTeamByPlayerName = lifted<IFunctionClient>("teams");
    const team = await getTeamByPlayerName.invoke(
      JSON.stringify({
        path: `/teams/cool`,
        method: "GET",
      })
    );
    console.log(team);
    return res as any[];
  }

  @Get("{playerId}")
  public async getUser(@Path() playerId: string): Promise<Player | undefined> {
    const db = lifted<IDatabase$Inflight>("db");
    const res = (await db.query(`SELECT * FROM players WHERE id = ${playerId};`)) as any[];
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
      const getTeamByPlayerName = lifted<IFunctionClient>("teams");
      team = await getTeamByPlayerName.invoke(
        JSON.stringify({
          path: `/teams/${name}`,
          method: "GET",
        })
      );
      if (!team) {
        this.setStatus(400);
        return -1;
      }
      team = JSON.parse(JSON.parse(team).body).name
    }

    const db = lifted<IDatabase$Inflight>("db");
    const res = (await db.query(`
      INSERT INTO players (name, team) 
      VALUES ('${name}', '${team}')
      RETURNING id;`)) as any[];
    await downloadImage(res[0].id);
    return res[0].id;
  }
}
