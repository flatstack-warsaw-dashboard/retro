<script context="module" lang="ts">
  export enum Mode {Show, Edit, Readonly};
</script>

<script lang="ts">
  import {Note} from "./models";
  import {currentUser} from "./store";
  import {TextArea, Form} from "carbon-components-svelte";
  import Misuse16 from "carbon-icons-svelte/lib/Misuse16";
  import {createEventDispatcher} from "svelte";

  const dispatch = createEventDispatcher();

  export let column: string;
  export let note: Note;

  export let mode: Mode;
  mode ||= note.persisted() ? Mode.Show : Mode.Edit;

  let show, edit, readonly, actionsAllowed = false;

  $: {
    show = mode == Mode.Show;
    edit = mode == Mode.Edit;
    readonly = mode == Mode.Readonly;
    actionsAllowed = !readonly && note.user.id == $currentUser.id;
  }

  let handleDblClick = (event) => {
    if (actionsAllowed && mode != Mode.Edit) {
      let modeWas = mode;
      mode = Mode.Edit;

      dispatch("modeChange", { mode: [modeWas, mode] })
    }
  }

  let handleNoteSave = (event) => {
    let modeWas = mode;

    note.save((model) => {
      mode = Mode.Show;

      dispatch("modeChange", { mode: [modeWas, mode] });
    })
  }

  let handleNoteDestroy = (event) => {
    note.destroy(() => {
      dispatch("modelDestroy", { model: note });
    });
  }

  let handleKeydown = (event) => {
    if(event.which === 13 && !event.shiftKey) {
      event.target.form.dispatchEvent(new Event("submit", { cancelable: true }));
      event.preventDefault(); // Prevents the addition of a new line in the text field (not needed in a lot of cases)
    }
  }
</script>

<div class="note bx--tile">
    {#if edit}
        <Form on:submit={handleNoteSave}>
            <TextArea placeholder="Add a note and press Enter..." rows="3" bind:value={note.text} on:keydown={handleKeydown}/>
        </Form>
    {:else}
        <div class="content" class:show class:disabled={readonly} on:dblclick={handleDblClick}>
            {#if actionsAllowed}
                <span class="bx--tile__checkmark destroy">
                    <Misuse16 on:click={handleNoteDestroy}/>
                </span>
            {/if}

            <p>{note.text}</p>

            <span class="bx--tile__chevron author">{note.user.name}</span>
        </div>
    {/if}
</div>

<style>
    .note {
        margin-top: 1rem;
        position: relative;
    }

    .note:hover .destroy{
        opacity: 1;
    }

    .content {
        padding: 1rem;
    }

    .content p {
        min-height: 2rem;
    }
</style>
