import {AttributesConstructor, Model, Collection} from "./model"
import {Board, BoardAttributes} from "./board";
import {User, UserAttributes} from "./user";

type NoteAttributes = {};

export class NoteAttributes implements AttributesConstructor {
  text?: string = null;
  retro_column?: string;
  _created_at?: string;
  _updated_at?: string;

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

  constructor(attrs: Partial<{ text: string, retro_column: string, created_at: string, updated_at: string }>) {
    if (attrs.text) {
      this.text = attrs.text
    }
    if (attrs.retro_column) {
      this.retro_column = attrs.retro_column
    }

    if (attrs.created_at) {
      this.created_at = new Date(attrs.created_at)
    }
    if (attrs.updated_at) {
      this.updated_at = new Date(attrs.updated_at)
    }
  }
}

export class Note extends Model<NoteAttributes> {
  public static readonly TYPE = "notes";

  user?: User;
  board?: Board;

  get type() {
    return Note.TYPE
  }

  get text() {
    return this.attributes.text;
  }

  set text(text) {
    this.attributes.text = text;
  }

  constructor(id?: string, attributes?: Partial<NoteAttributes>) {
    super(NoteAttributes, id, attributes);
  }

  parseRelationships(raw: any) {
    if (raw.data.user) {
      let {id: userId, ...userAttributes} = raw.data.user.data;

      this.user = new User(userId, new UserAttributes(userAttributes));
    }

    if (raw.data.board) {
      let {id: boardId, ...boardAttributes} = raw.data.board.data;

      this.board = new Board(boardId, new BoardAttributes(boardAttributes));
    }
  }

  relationships = (): any => {
    let relations = {};
    relations = {...(this.board && { board: this.board.identifier() })};
    relations = {...relations, ...(this.user && { user: this.user.identifier() })};

    return relations;
  }
}

export class NotesCollection extends Collection<Note> {
  constructor() {
    super(Note);
  }

  filterByColumn(columnName: string) {
    return this.models.filter((note) => { return note.attributes.retro_column === columnName });
  }
}
