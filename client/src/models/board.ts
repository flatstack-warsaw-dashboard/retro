import {Model, AttributesConstructor} from "./model";
import {User, UserAttributes} from "./user";
import {NotesCollection} from "./note"
import {BoardVersionsCollection} from "./board_version"

export class BoardAttributes implements AttributesConstructor {
  name?: string;
  retro_columns?: string[]
  _created_at?: string
  _updated_at?: string

  get created_at() {
    return new Date(this._created_at)
  }

  set created_at(date: Date) {
    this._created_at = date.toString();
  }

  get updated_at() {
    return new Date(this._updated_at)
  }

  set updated_at(date: Date) {
    this._updated_at = date.toString();
  }

  constructor(attrs: Partial<{ name: string, retro_columns: string[], created_at: string, updated_at: string }>) {
    if (attrs.name) {
      this.name = attrs.name
    }
    if (attrs.retro_columns) {
      this.retro_columns = attrs.retro_columns
    }

    if (attrs.created_at) {
      this.created_at = new Date(attrs.created_at)
    }
    if (attrs.updated_at) {
      this.updated_at = new Date(attrs.updated_at)
    }
  }
};

export class Board extends Model<BoardAttributes> {
  public static readonly TYPE = "boards";

  user: User;
  notes: NotesCollection;
  versions: BoardVersionsCollection;

  get type() {
    return Board.TYPE
  }

  get name() {
    return this.attributes.name;
  }

  set name(name) {
    this.attributes.name = name;
  }

  constructor(id?: string, attributes?: Partial<BoardAttributes>) {
    super(BoardAttributes, id, attributes);
  }

  parseRelationships(raw: any) {
    if (raw.data.user) {
      let {id: userId, ...userAttributes} = raw.data.user.data;

      this.user = new User(userId, new UserAttributes(userAttributes));
    }
  }

  fetchNotes = async (force = false) => {
    if (this.notes?.models.length && !force) {
      return this.notes;
    }

    this.notes = new NotesCollection();
    return await this.notes.fetch({"filter[board.id]": this.id});
  }

  fetchVersions = async (force = false) => {
    if (this.versions?.models.length && !force) {
      return this.versions;
    }

    this.versions = new BoardVersionsCollection();
    return await this.versions.fetch({"filter[board.id]": this.id});
  }
}
