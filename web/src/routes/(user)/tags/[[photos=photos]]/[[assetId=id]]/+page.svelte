<script lang="ts">
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import Button from '$lib/components/elements/buttons/button.svelte';
  import LinkButton from '$lib/components/elements/buttons/link-button.svelte';
  import Icon from '$lib/components/elements/icon.svelte';
  import UserPageLayout from '$lib/components/layouts/user-page-layout.svelte';
  import AssetGrid from '$lib/components/photos-page/asset-grid.svelte';
  import FullScreenModal from '$lib/components/shared-components/full-screen-modal.svelte';
  import {
    notificationController,
    NotificationType,
  } from '$lib/components/shared-components/notification/notification';
  import SettingInputField, {
    SettingInputFieldType,
  } from '$lib/components/shared-components/settings/setting-input-field.svelte';
  import SideBarSection from '$lib/components/shared-components/side-bar/side-bar-section.svelte';
  import TreeItemThumbnails from '$lib/components/shared-components/tree/tree-item-thumbnails.svelte';
  import TreeItems from '$lib/components/shared-components/tree/tree-items.svelte';
  import { AppRoute, AssetAction, QueryParameter } from '$lib/constants';
  import { createAssetInteractionStore } from '$lib/stores/asset-interaction.store';
  import { AssetStore } from '$lib/stores/assets.store';
  import { buildTree, normalizeTreePath } from '$lib/utils/tree-utils';
  import { deleteTag, getAllTags, updateTag, upsertTags, type TagResponseDto } from '@immich/sdk';
  import { mdiChevronRight, mdiPencil, mdiPlus, mdiTag, mdiTagMultiple, mdiTrashCanOutline } from '@mdi/js';
  import { t } from 'svelte-i18n';
  import type { PageData } from './$types';
  import { dialogController } from '$lib/components/shared-components/dialog/dialog';

  export let data: PageData;

  $: pathSegments = data.path ? data.path.split('/') : [];
  $: currentPath = $page.url.searchParams.get(QueryParameter.PATH) || '';

  const assetInteractionStore = createAssetInteractionStore();

  const buildMap = (tags: TagResponseDto[]) => {
    return Object.fromEntries(tags.map((tag) => [tag.value, tag]));
  };

  $: tags = data.tags;
  $: tagsMap = buildMap(tags);
  $: tag = currentPath ? tagsMap[currentPath] : null;
  $: tree = buildTree(tags.map((tag) => tag.value));

  const handleNavigation = async (tag: string) => {
    await navigateToView(normalizeTreePath(`${data.path || ''}/${tag}`));
  };

  const handleBreadcrumbNavigation = async (targetPath: string) => {
    await navigateToView(targetPath);
  };

  const getLink = (path: string) => {
    const url = new URL(AppRoute.TAGS, window.location.href);
    url.searchParams.set(QueryParameter.PATH, path);
    return url.href;
  };

  const getColor = (path: string) => tagsMap[path]?.color;

  const navigateToView = (path: string) => goto(getLink(path));

  let isNewOpen = false;
  let newTagValue = '';
  const handleCreate = () => {
    newTagValue = tag ? tag.value + '/' : '';
    isNewOpen = true;
  };

  let isEditOpen = false;
  let newTagColor = '';
  const handleEdit = () => {
    newTagColor = tag?.color ?? '';
    isEditOpen = true;
  };

  const handleCancel = () => {
    isNewOpen = false;
    isEditOpen = false;
  };

  const handleSubmit = async () => {
    if (tag && isEditOpen && newTagColor) {
      await updateTag({ id: tag.id, tagUpdateDto: { color: newTagColor } });

      notificationController.show({
        message: $t('tag_updated', { values: { tag: tag.value } }),
        type: NotificationType.Info,
      });

      tags = await getAllTags();
      isEditOpen = false;
    }

    if (isNewOpen && newTagValue) {
      const [newTag] = await upsertTags({ tagUpsertDto: { tags: [newTagValue] } });

      notificationController.show({
        message: $t('tag_created', { values: { tag: newTag.value } }),
        type: NotificationType.Info,
      });

      tags = await getAllTags();
      isNewOpen = false;
    }
  };

  const handleDelete = async () => {
    if (!tag) {
      return;
    }

    const isConfirm = await dialogController.show({
      title: $t('delete_tag'),
      prompt: $t('delete_tag_confirmation_prompt', { values: { tagName: tag.value } }),
      confirmText: $t('delete'),
      cancelText: $t('cancel'),
    });

    if (!isConfirm) {
      return;
    }

    await deleteTag({ id: tag.id });
    tags = await getAllTags();

    // navigate to parent
    const parentPath = pathSegments.slice(0, -1).join('/');
    await navigateToView(parentPath);
  };
</script>

<UserPageLayout title={data.meta.title} scrollbar={false}>
  <SideBarSection slot="sidebar">
    <section>
      <div class="text-xs pl-4 mb-2 dark:text-white">{$t('explorer').toUpperCase()}</div>
      <div class="h-full">
        <TreeItems icons={{ default: mdiTag, active: mdiTag }} items={tree} active={currentPath} {getLink} {getColor} />
      </div>
    </section>
  </SideBarSection>

  <section slot="buttons">
    <LinkButton on:click={handleCreate}>
      <div class="flex place-items-center gap-2 text-sm">
        <Icon path={mdiPlus} size="18" />
        <p class="hidden md:block">{$t('create_tag')}</p>
      </div>
    </LinkButton>

    <LinkButton on:click={handleEdit}>
      <div class="flex place-items-center gap-2 text-sm">
        <Icon path={mdiPencil} size="18" />
        <p class="hidden md:block">{$t('edit_tag')}</p>
      </div>
    </LinkButton>

    {#if pathSegments.length > 0 && tag}
      <LinkButton on:click={handleDelete}>
        <div class="flex place-items-center gap-2 text-sm">
          <Icon path={mdiTrashCanOutline} size="18" />
          <p class="hidden md:block">{$t('delete_tag')}</p>
        </div>
      </LinkButton>
    {/if}
  </section>

  <section
    class="flex place-items-center gap-2 mt-2 text-immich-primary dark:text-immich-dark-primary rounded-2xl bg-gray-50 dark:bg-immich-dark-gray/50 w-full py-2 px-4 border border-gray-100 dark:border-gray-900"
  >
    <a href={`${AppRoute.TAGS}`} title={$t('to_root')}>
      <Icon path={mdiTagMultiple} class="text-immich-primary dark:text-immich-dark-primary mr-2" size={28} />
    </a>
    {#each pathSegments as segment, index}
      <button
        class="text-sm font-mono underline hover:font-semibold"
        on:click={() => handleBreadcrumbNavigation(pathSegments.slice(0, index + 1).join('/'))}
        type="button"
      >
        {segment}
      </button>
      <p class="text-gray-500">
        {#if index < pathSegments.length - 1}
          <Icon path={mdiChevronRight} class="text-gray-500 dark:text-gray-300" size={16} />
        {/if}
      </p>
    {/each}
  </section>

  <section class="mt-2 h-full">
    {#key $page.url.href}
      {#if tag}
        <AssetGrid
          enableRouting={true}
          assetStore={new AssetStore({ tagId: tag.id })}
          {assetInteractionStore}
          removeAction={AssetAction.UNARCHIVE}
        >
          <TreeItemThumbnails items={data.children} icon={mdiTag} onClick={handleNavigation} slot="empty" />
        </AssetGrid>
      {:else}
        <TreeItemThumbnails items={Object.keys(tree)} icon={mdiTag} onClick={handleNavigation} />
      {/if}
    {/key}
  </section>
</UserPageLayout>

{#if isNewOpen}
  <FullScreenModal title={$t('create_tag')} icon={mdiTag} onClose={handleCancel}>
    <div class="text-immich-primary dark:text-immich-dark-primary">
      <p class="text-sm dark:text-immich-dark-fg">
        {$t('create_tag_description')}
      </p>
    </div>

    <form on:submit|preventDefault={handleSubmit} autocomplete="off" id="create-tag-form">
      <div class="my-4 flex flex-col gap-2">
        <SettingInputField
          inputType={SettingInputFieldType.TEXT}
          label={$t('tag').toUpperCase()}
          bind:value={newTagValue}
          required={true}
          autofocus={true}
        />
      </div>
    </form>
    <svelte:fragment slot="sticky-bottom">
      <Button color="gray" fullwidth on:click={() => handleCancel()}>{$t('cancel')}</Button>
      <Button type="submit" fullwidth form="create-tag-form">{$t('create')}</Button>
    </svelte:fragment>
  </FullScreenModal>
{/if}

{#if isEditOpen}
  <FullScreenModal title={$t('edit_tag')} icon={mdiTag} onClose={handleCancel}>
    <form on:submit|preventDefault={handleSubmit} autocomplete="off" id="edit-tag-form">
      <div class="my-4 flex flex-col gap-2">
        <SettingInputField
          inputType={SettingInputFieldType.COLOR}
          label={$t('color').toUpperCase()}
          bind:value={newTagColor}
        />
      </div>
    </form>
    <svelte:fragment slot="sticky-bottom">
      <Button color="gray" fullwidth on:click={() => handleCancel()}>{$t('cancel')}</Button>
      <Button type="submit" fullwidth form="edit-tag-form">{$t('save')}</Button>
    </svelte:fragment>
  </FullScreenModal>
{/if}
