import {deserialise} from "kitsu-core";
import {Retro} from "../retro";

export interface AttributesConstructor<T = {}> {
  new(args): T;
}

type ModelIdentifier = {
  id: string;
  type: string;
}

export abstract class Model<Schema extends AttributesConstructor> {
  abstract type: string;

  static apiPath = Retro.api_path;
  static jwtToken = null;

  get endpoint() {
    return `${Model.apiPath}/${this.type}`;
  }

  static requestHeaders = () => {
    return ({
      'Content-Type': 'application/vnd.api+json;charset=UTF-8',
      ...(Model.jwtToken && {'Authorization': `Bearer ${Model.jwtToken}`})
    })
  }

  id?: string;
  attributesConstructor: AttributesConstructor<Schema>;
  _attributes: Schema;
  collection?: Collection<Model<Schema>>;

  constructor(ctor: AttributesConstructor<Schema>, id?: string, _attributes?: Partial<Schema>) {
    this.id = id;
    this.attributesConstructor = ctor;

    this.attributes = _attributes || new ctor({});
  }

  get attributes() {
    return this._attributes;
  }

  set attributes(attrs) {
    this._attributes = attrs;
  }

  identifier = (): ModelIdentifier => {
    return { id: this.id, type: this.type };
  }

  persisted = () => {
    return !!this.id;
  }

  parseRelationships(raw: any): void {
  }

  relationships(): any {
    return {}
  }

  isEmpty(): boolean {
    return !(Object.keys(this.attributes).length > 0);
  }

  async find(ignoreIdError = false): Promise<Model<Schema>> | null {
    if (!ignoreIdError && !this.id) {
      throw new Error("Model id is missing.");
    }

    const findParams = this.id ? {id: this.id} : {}
    const response = await window.fetch(this.resourceURL("show", findParams), {
      method: "GET",
      headers: Model.requestHeaders(),
    });

    if (response.ok) {
      return this.assignAttributes(await response.json());
    } else {
      return null;
    }
  }

  async save(
    success?: (instance: Model<Schema>) => void,
    failure?: (instance: Model<Schema>) => void
  ): Promise<Model<Schema>> | null {
    const response = await window.fetch(this.resourceURL(this.id ? "update" : "create"), {
      method: this.persisted() ? "PATCH" : "POST",
      headers: Model.requestHeaders(),
      body: JSON.stringify({
        id: this.id,
        type: this.type,
        data: {
          id: this.id, attributes: this.attributes, relationships: this.relationships()
        }
      })
    });

    if (response.ok) {
      this.assignAttributes(await response.json());
      if (success) { success(this) };

      return this;
    } else {
      if (failure) { failure(this) };

      return null;
    }
  }

  async destroy(
    success?: (instance: Model<Schema>) => void,
    failure?: (instance: Model<Schema>) => void
  ): Promise<Model<Schema>> | null {
    if (!this.persisted()) { return null; }

    const response = await window.fetch(this.resourceURL("destroy"), {
      method: "DELETE",
      headers: Model.requestHeaders(),
      body: JSON.stringify({ id: this.id, type: this.type })
    });

    if (response.ok) {
      this.collection?.delete(this);
      if (success) { success(this) };

      return this;
    } else {
      if (failure) { failure(this) };

      return null;
    }
  }

  assignAttributes(attrs: any, deserialized?: any) {
    const model = deserialized || deserialise(attrs);

    let {id: modelId, ...modelAttributes} = model.data;
    this.id = modelId;
    this.attributes = new this.attributesConstructor(modelAttributes);
    this.parseRelationships(model);

    return this;
  }

  private production(): boolean {
    return Retro.production;
  }

  private resourceURL(action: string, params?: Record<string, string>): string {
    let url = new URL(this.endpoint)
    let searchParams = new URLSearchParams(params)

    url.pathname += "/" + action;
    url.search = searchParams.toString()

    return url.toString();
  }
}

export class Collection<T extends Model<Schema extends AttributesConstructor>> {
  models: T[] = [];

  get endpoint() {
    return `${Model.apiPath}/${this.ctor.TYPE}`
  }

  constructor(public ctor: T) {
  }

  find = (id: string) => {
    return this.models.find(item => item.id === id)
  }

  maximum = (func: (item: T) => any) => {
    return this.models.reduce((prev, current) => (func(prev) > func(current) ? prev : current))
  }

  fetch = async (params?: Record<string, string>): Promise<T[]> => {
    this.models = [];
    const response = await window.fetch(this.resourceURL("index", params), {
      method: "GET",
      headers: Model.requestHeaders(),
    });

    if (response.ok) {
      const collectionJson = deserialise(await response.json());
      for(let attrs of collectionJson.data) {
        let {id: relId, ...relData} = attrs;
        this.add((new this.ctor(relId)).assignAttributes(null, {data: attrs}));
      }
      return this.models;
    } else {
      return null;
    }
  }

  add = (model: T): T => {
    if (model.collection == this) { return };

    model.collection = this;
    this.models = [...this.models, model];

    return model;
  }

  delete = (model: T): T => {
    this.models = this.models.filter((m => m != model))

    return model
  }

  private resourceURL(action: string, params?: Record<string, string>): string {
    let url = new URL(this.endpoint)
    let searchParams = new URLSearchParams(params)

    url.pathname += "." + action;
    url.search = searchParams.toString();

    return url.toString();
  }
}
