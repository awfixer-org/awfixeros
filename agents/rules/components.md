# Custom Components in CMS Platforms (Payload, Tina, Sanity)

Custom Components allow you to fully customize the Admin Panels of various CMS platforms by swapping in your own React components. You can replace nearly every part of the interface or add entirely new functionality. This document primarily focuses on Payload CMS but includes notes on adapting components for TinaCMS and Sanity, as our projects use all three CMS platforms. Components must be designed to work across these systems where possible, prioritizing reusability and modularity.

## Migration and Organization Guidelines

We are aiming to migrate all components to a global components directory (e.g., `/global-components/`) that serves as a centralized repository for an assortment of components, blocks, and other UI items such as wallpapers, animations, icons, and reusable patterns. This promotes code reuse across projects and reduces duplication.

- **Global Directory Structure Example:**
  - `/global-components/components/` (core reusable components like buttons, modals)
  - `/global-components/blocks/` (composable blocks for content editing, e.g., hero blocks, galleries)
  - `/global-components/ui-items/` (miscellaneous items like wallpapers, animations, loaders)
  - `/global-components/utilities/` (helper functions or hooks shared across CMS)

- **Migration Process for Subdirectory Projects:**
  - Identify components in project-specific subdirectories (e.g., `/projects/my-project/components/`).
  - Evaluate reusability: If a component is generic and not tied to project-specific logic, migrate it to the global directory.
  - Refactor for compatibility: Ensure the component uses standard React practices and avoids CMS-specific dependencies. Use adapters or wrappers for CMS-specific features (e.g., a wrapper for Payload's `useField` hook that falls back to equivalents in Tina or Sanity).
  - Test across CMS: After migration, test the component in Payload, Tina, and Sanity admin panels.
  - Update imports: Replace local imports with paths or aliases pointing to the global directory (e.g., via import maps or package.json aliases).
  - Document: Add README.md in the global directory with usage examples for each CMS.

- **Prebuilt Components Preference:**
  - Prefer prebuilt components from the global directory or third-party libraries (e.g., Radix UI, Tailwind UI) to speed up development and maintain consistency.
  - If a suitable prebuilt component isn't available, copy and adapt existing ones to `/components/custom/` in the project root as a temporary measure. Plan to generalize and migrate these to the global directory in future iterations.

Components need to be compatible with Payload CMS, TinaCMS, and Sanity. Design them as pure React components where possible, using CMS-specific hooks or APIs only through optional props or wrappers. For example:
- In Payload: Use `useField` from `@payloadcms/ui`.
- In Tina: Use Tina's field plugins and `useForm` hook.
- In Sanity: Use Sanity's `PatchEvent` and studio components from `@sanity/ui`.

## Component Types

There are four main types of Custom Components (adapted across CMS):

1. **Root Components** - Affect the Admin Panel globally (logo, nav, header).
2. **Collection/Content Type Components** - Specific to collection or content type views (e.g., collections in Payload, content models in Tina/Sanity).
3. **Global/Singleton Components** - Specific to global or singleton document views.
4. **Field Components** - Custom field UI and cells.

Adaptations:
- **TinaCMS:** Focus on field plugins and custom forms.
- **Sanity:** Use portable text blocks, custom inputs, and desk structure customizations.

## Defining Custom Components

### Component Paths

Components are defined using file paths (not direct imports) to keep configs lightweight and Node.js compatible. Prefer paths relative to the global components directory.

```typescript
// Payload Example
import { buildConfig } from 'payload'

export default buildConfig({
  admin: {
    components: {
      logout: {
        Button: '/global-components/components/Logout#MyComponent', // Named export from global dir
      },
      Nav: '/global-components/components/Nav', // Default export from global dir
    },
  },
})
```

**Component Path Rules:**

1. Paths are relative to project root (or CMS-specific baseDir/importMap).
2. For **named exports**: append `#ExportName` or use `exportName` property.
3. For **default exports**: no suffix needed.
4. File extensions can be omitted.
5. For Tina/Sanity: Use similar path resolutions in their config files (e.g., Tina's `defineSchema` or Sanity's `plugins`).

### Component Config Object

Instead of a string path, you can pass a config object (adapt for each CMS):

```typescript
// Payload Example
{
  logout: {
    Button: {
      path: '/global-components/components/Logout',
      exportName: 'MyComponent',
      clientProps: { customProp: 'value' },
      serverProps: { asyncData: someData },
    },
  },
}
```

**Config Properties:**

| Property      | Description                                           |
| ------------- | ----------------------------------------------------- |
| `path`        | File path to component (named exports via `#`)        |
| `exportName`  | Named export (alternative to `#` in path)             |
| `clientProps` | Props for Client Components (must be serializable)    |
| `serverProps` | Props for Server Components (can be non-serializable) |

For TinaCMS/Sanity: Use equivalent prop passing in field definitions or custom inputs.

### Setting Base Directory

```typescript
// Payload Example
import path from 'path'
import { fileURLToPath } from 'node:url'

const filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(filename)

export default buildConfig({
  admin: {
    importMap: {
      baseDir: path.resolve(dirname, 'global-components'), // Set to global dir
    },
    components: {
      Nav: '/components/Nav', // Relative to global-components/
    },
  },
})
```

For TinaCMS: Use import aliases in `tsconfig.json`. For Sanity: Configure parts or plugins with paths to global dir.

## Server vs Client Components

**All components are React Server Components by default** (where supported, e.g., in Payload/Next.js setups). Adapt for Tina (client-side heavy) and Sanity (studio is client-based).

### Server Components (Default)

Can use Local API directly, perform async operations, and access full CMS instance.

```tsx
// Payload Example
import React from 'react'
import type { Payload } from 'payload'

async function MyServerComponent({ payload }: { payload: Payload }) {
  const page = await payload.findByID({
    collection: 'pages',
    id: '123',
  })

  return <p>{page.title}</p>
}

export default MyServerComponent
```

For Tina/Sanity: Use server-side fetching via APIs or GraphQL queries.

### Client Components

Use the `'use client'` directive for interactivity, hooks, state, etc.

```tsx
'use client'
import React, { useState } from 'react'

export function MyClientComponent() {
  const [count, setCount] = useState(0)

  return <button onClick={() => setCount(count + 1)}>Clicked {count} times</button>
}
```

**Important:** Client Components cannot receive non-serializable props. Each CMS strips these automatically when needed.

## Default Props

Custom Components receive CMS-specific default props. Design components to accept optional props for cross-compatibility:

| Prop      | Description                              | Type      | CMS Notes |
| --------- | ---------------------------------------- | --------- | --------- |
| `cmsInstance` | CMS instance (e.g., Local API access)    | Varies    | Payload: `Payload`; Tina: Form API; Sanity: Client |
| `i18n`    | Internationalization object              | `I18n`    | Supported in all |
| `locale`  | Current locale (if localization enabled) | `string`  | Supported in all |

**Server Component Example (Payload):**

```tsx
async function MyComponent({ payload, i18n, locale }) {
  const data = await payload.find({
    collection: 'posts',
    locale,
  })

  return <div>{data.docs.length} posts</div>
}
```

Adapt for Tina/Sanity by passing equivalent props.

**Client Component Example:**

```tsx
'use client'
// Payload hook example; use equivalents for Tina/Sanity
import { usePayload, useLocale, useTranslation } from '@payloadcms/ui'

export function MyComponent() {
  const { getLocal, getByID } = usePayload()
  const locale = useLocale()
  const { t, i18n } = useTranslation()

  return <div>{t('myKey')}</div>
}
```

For cross-CMS: Create a wrapper hook that detects the CMS and uses the appropriate import.

## Custom Props

Pass additional props using CMS-specific config (e.g., `clientProps` in Payload). Receive in component as standard React props.

## Root Components

Root Components affect the entire Admin Panel. Adapt paths to global dir.

### Available Root Components (Payload Focus)

| Component         | Description                      | Config Path                        | Tina/Sanity Equivalent |
| ----------------- | -------------------------------- | ---------------------------------- | ---------------------- |
| `Nav`             | Entire navigation sidebar        | `admin.components.Nav`             | Tina: Custom sidebar; Sanity: Desk structure |
| `graphics.Icon`   | Small icon (used in nav)         | `admin.components.graphics.Icon`   | Similar in UI plugins |
| ... (rest as in original) | ... | ... | Adapt as needed |

### Example: Custom Logo

Use global dir path.

```typescript
// Payload
export default buildConfig({
  admin: {
    components: {
      graphics: {
        Logo: '/global-components/components/Logo',
        Icon: '/global-components/components/Icon',
      },
    },
  },
})
```

For Tina: Define in `tina/config.tsx`. For Sanity: In `sanity.config.ts`.

```tsx
// global-components/components/Logo.tsx
export default function Logo() {
  return <img src="/logo.png" alt="My Brand" width={200} />
}
```

### Example: Header Actions

Similar, with paths to global dir.

## Collection/Content Type Components

Specific to collections/content types. Use global dir for components.

Payload Example (adapt for Tina/Sanity):

```typescript
import type { CollectionConfig } from 'payload'

export const Posts: CollectionConfig = {
  slug: 'posts',
  admin: {
    components: {
      edit: {
        PreviewButton: '/global-components/components/PostPreview',
        // ...
      },
      list: {
        // ...
      },
    },
  },
  fields: [
    // ...
  ],
}
```

For Tina: Use in schema definitions. For Sanity: Custom views in desk.

## Global/Singleton Components

Similar to above, for globals/singletons.

## Field Components

Customize fields. Prefer global dir.

### Field Component (Edit View)

Payload Example:

```typescript
{
  name: 'status',
  type: 'select',
  options: ['draft', 'published'],
  admin: {
    components: {
      Field: '/global-components/components/StatusField',
    },
  },
}
```

```tsx
// global-components/components/StatusField.tsx
'use client'
import { useField } from '@payloadcms/ui' // Adapt with conditional imports for Tina/Sanity
import type { SelectFieldClientComponent } from 'payload'

export const StatusField: SelectFieldClientComponent = ({ path, field }) => {
  const { value, setValue } = useField({ path })

  return (
    <div>
      <label>{field.label}</label>
      <select value={value} onChange={(e) => setValue(e.target.value)}>
        {field.options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </div>
  )
}
```

For Tina: Use `tina-field`. For Sanity: Custom input component.

### Cell Component (List View)

Similar adaptations.

### UI Field (Presentational Only)

Supported in Payload; emulate in Tina/Sanity with custom fields.

## Using Hooks

Each CMS has hooks. Create abstractions in global dir for cross-use.

Payload Example (as original). For Tina: `useForm`, `useCMS`. For Sanity: `useDocument`, `useCurrentUser`.

## Accessing CMS Config

Adapt per CMS, using global wrappers.

## Field Config Access

Similar.

## Translations (i18n)

Adapt `getTranslation` or hooks per CMS.

## Styling Components

Use CSS variables and SCSS imports. Ensure styles are CMS-agnostic (e.g., use Tailwind for consistency).

## Common Patterns

Adapt examples for multi-CMS, using conditional logic if needed.

## Performance Best Practices

Apply generally across CMS.

## Import Map

Payload-specific; for others, use tsconfig aliases or webpack configs.

## Type Safety

Use types from each CMS; create union types in global dir.

## Troubleshooting

Add CMS-specific notes.

## Resources

Add links for Tina and Sanity:
- [TinaCMS Custom Fields](https://tina.io/docs/reference/fields/custom-fields/)
- [Sanity Custom Inputs](https://www.sanity.io/docs/custom-input-components)
- Original Payload links.
