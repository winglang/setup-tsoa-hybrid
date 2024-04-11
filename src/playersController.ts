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

import { IBucketClient, IFunctionClient } from "@winglang/sdk/lib/cloud";

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
    const store: IBucketClient = lifted("playersStore");
    const player = await store.tryGet(playerId);
    if (!player) {
      this.setStatus(404);
      return;
    }
    return JSON.parse(player);
  }

  @SuccessResponse("201", "Created")
  @Post()
  public async createUser(
    @Body() requestBody: PlayerCreationParams
  ): Promise<void> {
    this.setStatus(201);
    const playerId = Math.random().toString().slice(-6);
    let team = requestBody.team;
    if (!team) {
      const getTeamByPlayerId: IFunctionClient = lifted("getTeamByPlayerId");
      team = await getTeamByPlayerId.invoke(playerId) as string
    }
    const store = lifted("playersStore");
    const player: Player = {
      id: playerId,
      team,
      name: requestBody.name,
    }
    await store.put(player.id, JSON.stringify(player));
    return;
  }
}
