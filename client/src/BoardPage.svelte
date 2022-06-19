<script lang="ts">
  import {Grid, Row, Loading, Button, ComboBox} from "carbon-components-svelte";
  import RetroColumn from "./RetroColumn.svelte";
  import {Board, BoardVersion, BoardVersionsCollection, RollforwardBoardVersion} from "./models";

  import {getMarkdownTable} from 'markdown-table-ts';

  import {get} from "svelte/store";
  import {currentUserBoards, currentUser} from "./store";
  import ActionsPanel from "./ActionsPanel.svelte";
  import {PathItem} from "./ActionsPanel.svelte";
  import RetroBoardVersion from "./RetroBoardVersion.svelte";

  import Archive16 from "carbon-icons-svelte/lib/Archive16";
  import Copy16 from "carbon-icons-svelte/lib/Copy16";

  export let boardId: string;
  const boards = get(currentUserBoards);
  const currentBoard = boards.find((b) => b.id == boardId) || new Board(boardId);

  let dataPromises: [Promise<any>];
  let markdownExportButton = null;
  let boardVersion = null;
  let isInHistoryMode = false;

  let markdownTableRows = (notesHolder: BoardVersion | Board) => {
    let columns: string[][] = [];

    for(let [i, column] of notesHolder.attributes.retro_columns.entries()) {
      columns[i] = notesHolder.notes.filterByColumn(column).map<string>((note) => { return note.text; });
    }
    const dimension = Math.max(...columns.map(c => c.length));

    return [...Array(dimension).keys()].map((c) => columns.map((row, r) => columns[r][c] || ''));
  }

  let exportMarkdownTable = async () => {
    markdownExportButton.disabled = true;

    let notesHolder = boardVersion || currentBoard;
    const table = getMarkdownTable(
      {
        table: {
          head: notesHolder.attributes.retro_columns,
          body: markdownTableRows(notesHolder)
        }
      }
    )
    await navigator.clipboard.writeText(table);

    markdownExportButton.disabled = false;
  }

  let archiveVersion = async (e) => {
    let boardVersion = new BoardVersion(null);
    boardVersion.board = currentBoard;

    dataPromises = await boardVersion.save().then(_ => loadData());
  }

  let rollforwardVersion = async (e) => {
    let rollforwardVersion = new RollforwardBoardVersion(null);
    rollforwardVersion.board = currentBoard;

    dataPromises = await rollforwardVersion.save().then(_ => loadData());
  }

  let loadData = () => {
    let promises: [Promise<any>] = [currentBoard.fetchNotes(true), currentBoard.fetchVersions(true)];
    if (currentBoard.isEmpty()) { promises.push(currentBoard.find()) };
    boardVersion = null;
    dataPromises = promises;

    return promises;
  }

  let currentPath = () => [
    new PathItem("/", "Dashboard", true),
    new PathItem(null, currentBoard.name)
  ];

  let prepareBoardVersionItems = (versions: BoardVersionsCollection) => {
    let arr = versions.models.map(version => {
      return({ id: version.id, text: `Version ${version.attributes.version}` });
    })

    return arr;
  }

  let handleBoardVersionSelect = (e) => {
    boardVersion = currentBoard.versions.find(e.detail.selectedId);
    isInHistoryMode = boardVersion && boardVersion != currentBoard.versions.maximum(version => version.attributes.version);
  }

  let handleBoardVersionClear = (_) => {
    boardVersion = null;
    isInHistoryMode = false;
  }

  $: loadData();
</script>

{#await Promise.all(dataPromises)}
    <Loading/>
{:then notes}
    <ActionsPanel path="{currentPath()}">
        {#if currentBoard.user.id === $currentUser.id}
            <span id="version_selector">
                <ComboBox
                        placeholder="Select board version"
                        items={prepareBoardVersionItems(currentBoard.versions)}
                        size="sm"
                        on:select={handleBoardVersionSelect}
                        on:clear={handleBoardVersionClear} />
            </span>

            <Button disabled={isInHistoryMode}
                    on:click={rollforwardVersion}
                    kind="tertiary"
                    size="small"
                    icon={Copy16}
                    iconDescription="Copy notes to next version" />

            <Button disabled={isInHistoryMode}
                    on:click={archiveVersion}
                    size="small"
                    icon={Archive16}
                    iconDescription="Archive current version" />
        {/if}

        <Button bind:this={markdownExportButton}
                on:click={exportMarkdownTable}
                size="small"
                kind="secondary">Copy as Markdown</Button>
    </ActionsPanel>

    <Grid>
        <Row>
            {#if isInHistoryMode }
                <RetroBoardVersion boardVersion={boardVersion}/>
            {:else}
                {#each currentBoard.attributes.retro_columns as column}
                    <RetroColumn board={currentBoard} column={column}></RetroColumn>
                {/each}
            {/if}
        </Row>
    </Grid>
{/await}

<style>
    #version_selector {
        display: inline-block;
    }
</style>
