import {BoardVersion} from "./board_version";

export class RollforwardBoardVersion extends BoardVersion {
  public static readonly TYPE = "rollforwards";

  get type() {
    return RollforwardBoardVersion.TYPE
  }
}
