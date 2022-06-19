<script lang="ts">
  import {Board} from "./models/board";
  import type {NotesCollection} from "./models";
  import {Loading, Column, Row, Grid, Content, Dropdown, OutboundLink } from "carbon-components-svelte";
  import PublicNote from "./PublicNote.svelte";

  export let boardId: string;
  export let column: string = null;

  const currentBoard = new Board(boardId);
  let eventsWs: WebSocket;
  let notes: NotesCollection;

  const subscribeToEvents = () => {
    const ws = new WebSocket("wss://ws.retro.asktim.ru/s");

    ws.onmessage = (event) => {
      console.log(event.data);
      const data = JSON.parse(event.data);

      if ("success" in data) {
        // response to command received
      } else if ("topic" in data) {
        if (data.topic === `boards/${boardId}/touch`) {
          dataPromises = Promise.all([currentBoard.fetchNotes(true)]);
          dataPromises.then(() => notes = currentBoard.notes);
        }
      }
    }

    ws.onopen = () => {
      ws.send(JSON.stringify({command: "Sub", topic: `boards/${boardId}/touch`}));
      ws.send(JSON.stringify({command: "Sub", topic: `boards/${boardId}/delete`}));
      ws.send(JSON.stringify({command: "ListSub"}));
    }

    ws.onclose = (event) => {
      eventsWs = subscribeToEvents();
    }

    return ws;
  }

  let dataPromises = Promise.all([currentBoard.find(), currentBoard.fetchNotes()]);
  dataPromises
    .then(() => {
      column ||= currentBoard.attributes.retro_columns[0];
      notes = currentBoard.notes;
    })
    .then(() => eventsWs = subscribeToEvents());

  const handleBoardColumnSelect = (selectEvent) => {
    column = selectEvent.detail.selectedItem.text;
  }

</script>

<Content class="app--body">
    {#await dataPromises}
        <Loading withOverlay={false}/>
    {:then _promises}
        <Grid>
            <Row>
                <Column>
                    <div class="inside">
                        <h3 id="column_name">
                            <OutboundLink href="APP_URL/boards/{currentBoard.id}" size="lg">
                                <b>{currentBoard.attributes.name}</b>
                            </OutboundLink>

                            <span class="column-chooser">
                                <Dropdown type="inline"
                                          size="lg"
                                          selectedId={currentBoard.attributes.retro_columns.indexOf(column)}
                                          items={currentBoard.attributes.retro_columns.map((v, i) => { return { id: i, text: v } })}
                                          on:select={handleBoardColumnSelect}/>
                            </span>
                        </h3>

                        {#each notes.filterByColumn(column) as note}
                            <PublicNote column={column} note={note}/>
                        {/each}
                    </div>
                </Column>
            </Row>
        </Grid>
    {/await}
</Content>

<style>
    :global(:host) {
        height: 100%;
        overflow-y: scroll;
    }

    #column_name {
        line-height: 2rem;
        vertical-align: middle;
    }

    #column_name b {
        font-size: x-large;
    }

    .column-chooser {
        float: right;
    }
</style>
