<script lang="ts">
  import {Column, Form, TextArea} from "carbon-components-svelte";
  import {Board, Note} from "./models";
  import {currentUser} from "./store";
  import RetroNote from "./RetroNote.svelte";

  export let board: Board;
  export let column: string;

  let buildNewNote = () => {
    let note = new Note(null, {retro_column: column, text: null});
    note.board = board;
    note.user = $currentUser;

    return note;
  }

  let handleNewNoteKeydown = (event) => {
    if(event.which === 13 && !event.shiftKey) {
      event.target.form.dispatchEvent(new Event("submit", { cancelable: true }));
      event.preventDefault(); // Prevents the addition of a new line in the text field (not needed in a lot of cases)
    }
  }

  let handleNewNoteSave = (event) => {
    newNote.save((note) => {
      board.notes.add(note);
      newNote = buildNewNote();
      newNoteRef.value = newNote.text;

      currentColumnNotes = [...currentColumnNotes, note];
    });
  }

  let handleNoteDestroy = (event) => {
    currentColumnNotes = board.notes.filterByColumn(column);
  }

  let newNote = buildNewNote();
  let newNoteRef = null;

  $: currentColumnNotes = board.notes.filterByColumn(column);
</script>

<Column>
    <div class="inside">
        <h3 id="column_name">{column}</h3>

        <Form on:submit={handleNewNoteSave}>
            <TextArea placeholder="Add a note and press Enter..." rows="3" bind:ref={newNoteRef} bind:value={newNote.text} on:keydown={handleNewNoteKeydown}/>
        </Form>

        {#each currentColumnNotes as note}
            <RetroNote column={column} note={note} on:modelDestroy={handleNoteDestroy}></RetroNote>
        {/each}
    </div>
</Column>

<style>
    h3 {
        text-align: center;
    }
</style>
