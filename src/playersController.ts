import {
  Body,
  Controller,
  Get,
  Path,
  Post,
  Route,
  SuccessResponse,
} from "tsoa";

import { lifted } from "@winglibs/tsoa/clients.js"

import { IFunctionClient } from "@winglang/sdk/lib/cloud";

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
    return res[0].id;
  }
}
