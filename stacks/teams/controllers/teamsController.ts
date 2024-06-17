import { Controller, Get, Path, Route } from "tsoa";

export interface Team {
  name: string;
}

@Route("teams")
export class TeamsController extends Controller {
  @Get("{teamName}")
  public async getTeam(@Path() teamName: string): Promise<Team | undefined> {
    return {
      name: teamName,
    };
  }
}
