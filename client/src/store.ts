import {uniqueNamesGenerator, adjectives, colors, animals} from "unique-names-generator";

import {Model} from "./models/model";
import type {Board, NotesCollection} from "./models";

import {readable, writable} from "svelte/store";
import {User} from "./models";

export const currentUserBoards = writable<Board[]>([]);

const TOKEN_NAME = "jwt_token";

export const clearLocalJwtToken = () => {
  localStorage.removeItem(TOKEN_NAME);
  Model.jwtToken = null;
}

const useLocalJwtToken = (token?: string ) => {
  if (token) { localStorage.setItem(TOKEN_NAME, token) }

  const jwtToken = token || localStorage.getItem(TOKEN_NAME);

  if (jwtToken) {
    Model.jwtToken = jwtToken;
  }

  return jwtToken;
}

const generateUserName = () => {
  return uniqueNamesGenerator({dictionaries: [adjectives, colors, animals], separator: '-'});
}

export const currentUser = readable<User>(null, (set) => {
  let jwtToken = useLocalJwtToken();

  let user = new User(null, {name: generateUserName()});
  let result = (jwtToken ? user.find(true) : user.save()) as Promise<User>;

  result.then((user) => {
    if (user.token) {
      useLocalJwtToken(user.token.token);
    }

    set(user);
    currentUserBoards.set(user.boards);
  })

  return () => {};
});
