<script lang="ts">
  import {Column, Loading} from "carbon-components-svelte";
  import {BoardVersion} from "./models";
  import RetroNote from "./RetroNote.svelte";
  import {Mode} from "./RetroNote.svelte";

  export let boardVersion: BoardVersion;
</script>

{#await boardVersion.fetchNotes()}
    <Loading/>
{:then notes}
    {#each boardVersion.attributes.retro_columns as column}
        <Column>
            <div class="inside">
                <h3 id="column_name">{column}</h3>

                {#each boardVersion.notes.filterByColumn(column) as note}
                    <RetroNote column={column} note={note} mode={Mode.Readonly}></RetroNote>
                {/each}
            </div>
        </Column>
    {/each}
{/await}

<style>
    h3 {
        text-align: center;
    }
</style>
