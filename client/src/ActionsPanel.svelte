<script context="module" lang="ts">
  export class PathItem {
    constructor(
      public href: string,
      public caption: string,
      public navigate?: boolean) {}
  };
</script>

<script lang="ts">
  import {navigate} from "svelte-routing";
  import {Breadcrumb, BreadcrumbItem} from "carbon-components-svelte";

  export let path: PathItem[];

  function onNavigate(item) {
    return item.navigate && ((e) => { navigate("/"); e.preventDefault(); });
  }
</script>

<div class="actions-container">
    <Breadcrumb noTrailingSlash>
        {#each path as item, index}
            <BreadcrumbItem isCurrentPage={index == path.length-1} href={item.href} on:click={onNavigate(item)}>
                {item.caption}
            </BreadcrumbItem>
        {/each}
    </Breadcrumb>

    <span class="page-actions">
        <slot/>
    </span>
</div>

<style>
    .page-actions {
        position: absolute;
        top: 1rem;
        right: 1rem;
    }

    .actions-container {
        height: 3rem;
    }
</style>
