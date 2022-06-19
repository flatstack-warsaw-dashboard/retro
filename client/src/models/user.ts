import {Model, AttributesConstructor} from "./model";
import {Board, BoardAttributes} from "./board";

class JwtToken {
  constructor(public id: string, public token: string) {
  }
}

export class UserAttributes implements AttributesConstructor {
  name: string
  _created_at?: string

  get created_at() {
    return new Date(this._created_at)
  }

  set created_at(date: Date) {
    this._created_at = date.toString();
  }

  constructor(attrs: Partial<{ name: string, created_at: string }>) {
    this.name = attrs.name

    if (attrs.created_at) {
      this.created_at = new Date(attrs.created_at)
    }
  }
};

export class User extends Model<UserAttributes> {
  public static readonly TYPE = "users";

  token: JwtToken;
  boards: Board[]

  get type() {
    return User.TYPE
  }

  get name() {
    return this.attributes.name;
  }

  constructor(id?: string, attributes?: Partial<UserAttributes>) {
    super(UserAttributes, id, attributes);
  }

  parseRelationships(raw: any) {
    if (raw.data.jwt_token) {
      let rawToken = raw.data.jwt_token;
      this.token = new JwtToken(rawToken.id, rawToken.data.token);
    }

    if (raw.data.boards) {
      this.boards = [];

      for (let boardData of raw.data.boards.data) {
        let {id: boardId, ...boardAttributes} = boardData;
        let board = new Board(boardId, new BoardAttributes(boardAttributes));
        board.parseRelationships({data: boardAttributes});

        this.boards.push(board);
      }
    }
  }
}
