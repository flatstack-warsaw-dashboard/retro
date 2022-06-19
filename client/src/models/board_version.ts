import {Model, AttributesConstructor, Collection} from "./model";
import {Board} from "./board";
import {NotesCollection} from "./note";

export class BoardVersionAttributes implements AttributesConstructor {
  retro_columns?: string[]
  version: number
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

  constructor(attrs: Partial<BoardVersionAttributes>) {
    if (attrs.retro_columns) {
      this.retro_columns = attrs.retro_columns
    }
    if (attrs.hasOwnProperty("version")) {
      this.version = attrs.version
    }
    if (attrs.created_at) {
      this.created_at = new Date(attrs.created_at)
    }
    if (attrs.updated_at) {
      this.updated_at = new Date(attrs.updated_at)
    }
  }
};

export class BoardVersion extends Model<BoardVersionAttributes> {
  public static readonly TYPE = "board_versions";

  board: Board;
  notes: NotesCollection;

  get type() {
    return BoardVersion.TYPE
  }

  constructor(id?: string, attributes?: Partial<BoardVersionAttributes>) {
    super(BoardVersionAttributes, id, attributes);
  }

  parseRelationships(raw: any) {
    if (raw.data.board) {
      let {id: boardId} = raw.data.board.data;

      this.board = new Board(boardId);
    }
  }

  relationships = (): any => {
    let relations = {};
    relations = {...(this.board && { board: this.board.identifier() })};

    return relations;
  }

  fetchNotes = async () => {
    if (this.notes?.models.length) {
      return this.notes;
    }

    this.notes = new NotesCollection();
    return await this.notes.fetch({"filter[board_version.id]": this.id});
  }
}

export class BoardVersionsCollection extends Collection<BoardVersion> {
  constructor() {
    super(BoardVersion);
  }

  current = () => {
    return Math.max(...this.models.map(m => m.attributes.version))
  }
}
