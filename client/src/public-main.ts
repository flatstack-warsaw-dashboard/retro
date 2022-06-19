import type { SvelteComponent } from 'svelte';
import PublicApp from '../public/build/PublicApp.js';
import globalStyles from '../public/build/carbon-lite';
import styles from '../public/build/PublicApp.css';

class PublicAppComponent extends HTMLElement {
  _element: SvelteComponent;

  static boardId?: string;

  constructor() {
    super();

    const shadowRoot = this.attachShadow({ mode: 'open' });
    let styleTag = document.createElement("style");
    styleTag.setAttribute("type", "text/css");
    shadowRoot.append(styleTag);
    styleTag.appendChild(document.createTextNode(styles));
    styleTag.appendChild(document.createTextNode(globalStyles));

    // Instantiate the Svelte Component
    this._element = new PublicApp({
      // Tell it that it lives in the shadow root
      target: shadowRoot,

      props: {
        // This is the place where you do any conversion between
        // the native string attributes and the types you expect
        // in your svelte components
        boardId: this.constructor.boardId || this.getAttribute('board-id'),
      },
    })
  }

  disconnectedCallback(): void {
    // Destroy the Svelte component when this web component gets
    // disconnected. If this web component is expected to be moved
    // in the DOM, then you need to use `connectedCallback()` and
    // set it up again if necessary.
    this._element?.$destroy();
  }
}

customElements.define(
  'fwd-retro-board',
  PublicAppComponent
);

class PublicAdamantiumTeamComponent extends PublicAppComponent {};
PublicAdamantiumTeamComponent.boardId = "a97ab449-bde0-4be6-8485-41fb5580a4f5";

customElements.define(
  'fwd-retro-board-adamantium',
  PublicAdamantiumTeamComponent
);
