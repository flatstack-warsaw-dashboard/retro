<script lang="ts">
  import {
    Grid,
    Row,
    Column,
    Form,
    FormGroup,
    TextInput,
    Tile,
    Button,
    Breadcrumb,
    BreadcrumbItem
  } from "carbon-components-svelte";

  import {Board} from "./models/board";
  import {Link} from "svelte-routing";

  import {currentUserBoards} from "./store";

  import ActionsPanel from "./ActionsPanel.svelte";
  import {PathItem} from "./ActionsPanel.svelte";

  const enableNewBoardForm = () => { disableNewBoardForm = null; }

  const handleNewBoardSave = (event) => {
    event.preventDefault();
    disableNewBoardForm = true;

    newBoard.save(
      (_) => {
        $currentUserBoards = [...$currentUserBoards, newBoard];
        newBoard = new Board(null, { name: null });

        enableNewBoardForm();
      },
      enableNewBoardForm
    ).catch(enableNewBoardForm);
  }

  let newBoard = new Board();
  let disableNewBoardForm = null;

  const path = [new PathItem(null, "Dashboard")]
</script>

<ActionsPanel path={path}></ActionsPanel>

<Grid>
    <Row>
        <Column>
            <h3>Choose one of your boards</h3>

            <Tile>
                {#if $currentUserBoards.length > 0}
                    {#each $currentUserBoards as board}
                        <Link class="bx--tile bx--tile--clickable bx--link" to={`/boards/${board.id}`}>
                            {board.name}
                        </Link>
                    {/each}
                {:else}
                    Seems you have no boards yet.
                {/if}
            </Tile>
        </Column>
        <Column>
            <h3>Or create new one</h3>

            <Tile>
                <Form on:submit={handleNewBoardSave}>
                    <FormGroup legendText="Board Name" bind:disabled={disableNewBoardForm}>
                        <TextInput placeholder="Enter new board name..." bind:value={newBoard.name}/>
                    </FormGroup>
                    <Button type="submit" disabled={disableNewBoardForm}>Create</Button>
                </Form>
            </Tile>
        </Column>
    </Row>
</Grid>
