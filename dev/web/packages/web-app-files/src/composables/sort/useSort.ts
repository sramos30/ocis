import { ref, Ref, computed, ComputedRef, unref, isRef } from '@vue/composition-api'
import { MaybeRef, MaybeReadonlyRef } from 'web-pkg/src/utils'
import { useRouteName, useRouteQueryPersisted, QueryValue } from 'web-pkg/src/composables'
import { SortConstants } from './constants'

export interface SortableItem {
  type?: string
}

export enum SortDir {
  Desc = 'desc',
  Asc = 'asc'
}
export interface SortField {
  name: MaybeRef<string>
  // eslint-disable-next-line @typescript-eslint/ban-types
  sortable?: MaybeRef<boolean | Function | string>
  sortDir?: MaybeRef<SortDir>
}

export interface SortOptions<T extends SortableItem> {
  items: MaybeReadonlyRef<Array<T>>
  fields: MaybeRef<Array<SortField>>
  sortBy?: MaybeRef<string>
  sortByQueryName?: MaybeRef<string>
  sortDir?: MaybeRef<SortDir>
  sortDirQueryName?: MaybeRef<string>
  routeName?: MaybeRef<string>
}

export interface SortResult<T> {
  items: ComputedRef<Array<T>>
  sortBy: ComputedRef<string>
  sortDir: ComputedRef<SortDir>
  handleSort({ sortBy, sortDir }: { sortBy: string; sortDir: SortDir }): void
}

export function useSort<T extends SortableItem>(options: SortOptions<T>): SortResult<T> {
  const sortByRef = createSortByQueryRef(options)
  const sortDirRef = createSortDirQueryRef(options)

  const sortBy = computed(
    (): string =>
      firstQueryValue(unref(sortByRef)) || unref(firstSortableField(unref(fields))?.name)
  )
  const sortDir = computed((): SortDir => {
    return (
      sortDirFromQueryValue(unref(sortDirRef)) || defaultSortDirection(unref(sortBy), unref(fields))
    )
  })
  const fields = options.fields

  const items = computed<Array<T>>((): T[] => {
    // cast to T[] to avoid: Type 'T[] | readonly T[]' is not assignable to type 'T[]'.
    const sortItems = unref(options.items) as T[]

    if (!unref(sortBy)) {
      return sortItems
    }

    return sortHelper(sortItems, unref(fields), unref(sortBy), unref(sortDir))
  })

  const handleSort = ({ sortBy, sortDir }: { sortBy: string; sortDir: SortDir }) => {
    sortByRef.value = sortBy
    sortDirRef.value = sortDir
  }

  return {
    items,
    sortBy,
    sortDir,
    handleSort
  }
}

function createSortByQueryRef<T>(options: SortOptions<T>): Ref<QueryValue> {
  if (options.sortBy) {
    return isRef(options.sortBy) ? options.sortBy : ref(options.sortBy)
  }

  return useRouteQueryPersisted({
    name: unref(options.sortByQueryName) || SortConstants.sortByQueryName,
    defaultValue: unref(firstSortableField(unref(options.fields))?.name),
    routeName: unref(options.routeName || useRouteName())
  })
}

function createSortDirQueryRef<T>(options: SortOptions<T>): Ref<QueryValue> {
  if (options.sortDir) {
    return isRef(options.sortDir) ? options.sortDir : ref(options.sortDir)
  }

  return useRouteQueryPersisted({
    name: unref(options.sortDirQueryName) || SortConstants.sortDirQueryName,
    defaultValue: unref(firstSortableField(unref(options.fields))?.sortDir),
    routeName: unref(options.routeName || useRouteName())
  })
}

const firstSortableField = (fields: SortField[]): SortField => {
  const sortableFields = fields.filter((f) => f.sortable)
  if (sortableFields) {
    return sortableFields[0]
  }
  return null
}

const defaultSortDirection = (name: string, fields: SortField[]): SortDir => {
  const sortField = fields.find((f) => f.name === name)
  if (sortField && sortField.sortDir) {
    return unref(sortField.sortDir)
  }
  return SortDir.Desc
}

const sortHelper = <T extends SortableItem>(
  items: T[],
  fields: SortField[],
  sortBy: string,
  sortDir: SortDir
) => {
  const field = fields.find((f) => f.name === sortBy)
  if (!field) {
    return items
  }
  const { sortable } = field
  const collator = new Intl.Collator(navigator.language, { sensitivity: 'base', numeric: true })

  if (sortBy === 'name') {
    const folders = [...items.filter((i) => i.type === 'folder')].sort((a, b) =>
      compare(a, b, collator, sortBy, sortDir, sortable)
    )
    const files = [...items.filter((i) => i.type !== 'folder')].sort((a, b) =>
      compare(a, b, collator, sortBy, sortDir, sortable)
    )
    if (sortDir === SortDir.Asc) {
      return folders.concat(files)
    }
    return files.concat(folders)
  }
  return [...items].sort((a, b) => compare(a, b, collator, sortBy, sortDir, sortable))
}

const compare = (
  a: SortableItem,
  b: SortableItem,
  collator: Intl.Collator,
  sortBy: string,
  sortDir: SortDir,
  sortable
) => {
  let aValue = a[sortBy]
  let bValue = b[sortBy]
  const modifier = sortDir === SortDir.Asc ? 1 : -1

  if (sortable) {
    if (typeof sortable === 'string') {
      const genArrComp = (vals) => {
        return vals.map((val) => val[sortable]).join('')
      }

      aValue = genArrComp(aValue)
      bValue = genArrComp(bValue)
    } else if (typeof sortable === 'function') {
      aValue = sortable(aValue)
      bValue = sortable(bValue)
    }
  }

  if (!isNaN(aValue) && !isNaN(bValue)) {
    return (aValue - bValue) * modifier
  }
  const c = collator.compare((aValue || '').toString(), (bValue || '').toString())
  return c * modifier
}

const firstQueryValue = (value: QueryValue): string => {
  return Array.isArray(value) ? value[0] : value
}

const sortDirFromQueryValue = (value: QueryValue): SortDir | null => {
  switch (firstQueryValue(value)) {
    case SortDir.Asc:
      return SortDir.Asc
    case SortDir.Desc:
      return SortDir.Desc
  }

  return null
}
