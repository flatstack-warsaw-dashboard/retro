<script lang="ts">
  import "carbon-components-svelte/css/g10.css";

  import {
    Header,
    HeaderAction,
    HeaderUtilities,
    Content,
    Loading,
    HeaderPanelLinks,
    HeaderPanelDivider,
    HeaderPanelLink
  } from "carbon-components-svelte";

  import User24 from "carbon-icons-svelte/lib/User24";
  import {User} from "./models";
  import {currentUser, clearLocalJwtToken} from "./store";
  import {Router, Route} from "svelte-routing";
  import BoardPage from "./BoardPage.svelte"
  import HomePage from "./HomePage.svelte"

  export let path = "";

  let user: User;
</script>

{#if user = $currentUser }
    <Header company="Retro">
        <HeaderUtilities>
            <HeaderAction icon="{User24}" text={user.name}>
                <HeaderPanelLinks>
                    <HeaderPanelDivider>Settings</HeaderPanelDivider>
                    <HeaderPanelLink href="/" on:click={clearLocalJwtToken}>Reset user identity</HeaderPanelLink>
                </HeaderPanelLinks>
            </HeaderAction>
        </HeaderUtilities>
    </Header>
    <Content>
        <Router url={path}>
            <Route let:params path="/boards/:id">
                <BoardPage boardId={params.id}></BoardPage>
            </Route>
            <Route path="/">
                <HomePage></HomePage>
            </Route>
        </Router>
    </Content>
{:else}
    <Loading/>
{/if}

<style>
    main {
        text-align: center;
        padding: 1em;
        max-width: 240px;
        margin: 0 auto;
    }

    @media (min-width: 640px) {
        main {
            max-width: none;
        }
    }
</style>
