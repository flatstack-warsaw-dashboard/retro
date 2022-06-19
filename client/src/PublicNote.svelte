<script lang="ts">
  import {Note} from "./models";
  export let column: string;
  export let note: Note;
</script>

<div class="note bx--tile">
    <div class="content disabled">

        <p>{note.text}</p>

        <span class="bx--tile__chevron author">{note.user.name}</span>
    </div>
</div>

<style>
    .note {
        margin-top: 1rem;
        position: relative;
    }

    .content {
        padding: 1rem;
    }

    .content p {
        min-height: 2rem;
    }
</style>
