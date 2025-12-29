# Central Consolidation Plan

## Overview
This document outlines the strategy to consolidate global blocks, components, configs, and shared utilities across all projects (blog, pressroom, wiki, link) into a unified architecture for future migration to a single Vercel project.

**Excluded Projects**: proxy, awfixer.foundation, site, link

**Target Projects for Consolidation**:
- `/blog` - Next.js + TinaCMS
- `/pressroom` - Next.js + PayloadCMS  
- `/wiki` - VitePress

## Current State Analysis

### Shared Dependencies Identified
- **UI Framework**: All Next.js projects use Radix UI primitives
- **Styling**: Tailwind CSS across projects (except wiki - VitePress)
- **Component Libraries**: Similar button, card, input components with slight variations
- **Utilities**: clsx, tailwind-merge, class-variance-authority
- **Icons**: Lucide React
- **TypeScript**: Strict mode enabled

### Duplicated Components
1. **UI Components** (Button, Card, Input, Select, etc.)
   - `/blog/components/ui/button.tsx` 
   - `/pressroom/src/components/ui/button.tsx`
   - Similar variants but different implementations

2. **Layout Components**
   - Header/Footer patterns across projects
   - Navigation components
   - Section containers

3. **Block Components**
   - Hero sections (blog, pressroom)
   - Feature lists
   - Call-to-action components
   - Testimonials

4. **Utility Functions**
   - Date formatting
   - Image optimization
   - SEO utilities

## Proposed Architecture

### 1. Shared Package Structure
```
/packages
├── /ui                    # Shared UI component library
│   ├── components/        # Reusable UI components
│   ├── primitives/        # Radix UI wrappers
│   ├── hooks/            # Shared React hooks
│   └── styles/           # Global styles, theme
├── /config               # Shared configurations
│   ├── tailwind/         # Tailwind config
│   ├── typescript/       # TypeScript configs
│   ├── eslint/           # ESLint configs
│   └── next/            # Next.js configs
├── /utils               # Shared utilities
│   ├── date.ts
│   ├── seo.ts
│   ├── image.ts
│   └── validation.ts
└── /blocks              # Content blocks
    ├── hero/
    ├── features/
    ├── testimonials/
    └── cta/
```

### 2. Component Standardization

#### UI Component API
```typescript
// Standard component interface
interface ComponentProps {
  variant?: 'default' | 'secondary' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
  asChild?: boolean;
}
```

#### Design System Tokens
```typescript
// Shared theme configuration
export const theme = {
  colors: { /* unified color palette */ },
  spacing: { /* consistent spacing scale */ },
  typography: { /* shared typography */ },
  breakpoints: { /* responsive breakpoints */ }
};
```

### 3. Configuration Consolidation

#### Shared Next.js Config
```javascript
// Base configuration with project-specific overrides
const baseConfig = {
  reactStrictMode: true,
  swcMinify: true,
  experimental: { appDir: true },
  // Shared optimizations
};
```

#### Unified Tailwind Config
```javascript
// Single source of truth for design system
module.exports = {
  content: [/* all component sources */],
  theme: {
    extend: {
      colors: theme.colors,
      spacing: theme.spacing,
      fontFamily: theme.typography.fonts,
    }
  }
};
```

## Migration Strategy

### Phase 1: Extract Shared Packages
1. **Create `/packages/ui` library**
   - Extract common UI components
   - Standardize component APIs
   - Set up Storybook for documentation

2. **Create `/packages/config`**
   - Consolidate Tailwind configs
   - Create shared ESLint/TypeScript configs
   - Standardize build configurations

3. **Create `/packages/utils`**
   - Extract shared utility functions
   - Create comprehensive type definitions
   - Add unit tests

### Phase 2: Refactor Projects
1. **Update package.json dependencies**
   - Remove duplicate dependencies
   - Add references to shared packages
   - Standardize version management

2. **Migrate component imports**
   - Replace local components with shared ones
   - Update styling to use design tokens
   - Ensure backward compatibility

3. **Standardize configurations**
   - Adopt shared configs across projects
   - Remove project-specific duplicates
   - Set up consistent build pipelines

### Phase 3: Content Block Consolidation
1. **Create universal block system**
   - Design block interfaces that work across CMS platforms
   - Create adapters for TinaCMS, PayloadCMS, and Sanity
   - Implement block serialization/deserialization

2. **Migrate existing blocks**
   - Standardize block props and data structures
   - Create migration scripts
   - Update CMS schemas

### Phase 4: Single Project Migration
1. **Create monorepo structure**
   - Set up Nx or Lerna for workspace management
   - Configure shared builds and deployments
   - Implement CI/CD pipeline

2. **Consolidate routing**
   - Design unified routing strategy
   - Implement project prefixes (/blog, /pressroom, /wiki)
   - Handle project-specific middleware

## Implementation Details

### Component Sharing Strategy
```typescript
// Dynamic component loading for CMS-specific needs
export const createBlockAdapter = (cms: 'tinacms' | 'payload' | 'sanity') => {
  return {
    Hero: adaptHeroBlock(cms),
    Features: adaptFeaturesBlock(cms),
    // ... other blocks
  };
};
```

### CSS Architecture
```css
/* Global design system */
:root {
  --color-primary: /* theme token */;
  --spacing-md: /* spacing token */;
  --font-sans: /* typography token */;
}

/* Component-specific styles */
.ui-button { /* base styles */ }
.ui-button--variant-secondary { /* variant styles */ }
```

### Type Safety
```typescript
// Shared types across all projects
export interface BlockProps {
  id: string;
  type: BlockType;
  data: Record<string, unknown>;
  settings?: BlockSettings;
}

export interface CMSAdapter<T = any> {
  parse(data: T): BlockProps;
  serialize(block: BlockProps): T;
}
```

## Benefits

1. **Consistency**: Unified design system across all projects
2. **Maintainability**: Single source of truth for components and configs
3. **Performance**: Reduced bundle sizes through tree-shaking
4. **Development Speed**: Shared components reduce duplicated work
5. **Testing**: Centralized testing for core components
6. **Type Safety**: Shared TypeScript definitions

## Challenges & Solutions

### Challenge: CMS-Specific Requirements
**Solution**: Create adapter pattern for CMS-specific implementations
- TinaCMS adapters for blog
- PayloadCMS adapters for pressroom
- Sanity adapters for site (when included)

### Challenge: Different Styling Needs
**Solution**: Extendable theme system with project-specific overrides
- Base theme in shared package
- Project-specific theme extensions
- CSS custom properties for dynamic theming

### Challenge: Build Process Complexity
**Solution**: Gradual migration path with backward compatibility
- Maintain existing projects during migration
- Feature flags for new shared components
- Automated testing for cross-project compatibility

## Timeline

**Phase 1 (2-3 weeks)**: Extract and create shared packages
**Phase 2 (2-3 weeks)**: Refactor existing projects
**Phase 3 (2-3 weeks)**: Consolidate content blocks
**Phase 4 (3-4 weeks)**: Single project migration

**Total Estimated Timeline**: 9-13 weeks

## Success Metrics

- [ ] Reduction of duplicate code by 70%+
- [ ] Consistent component APIs across all projects
- [ ] Unified design system implementation
- [ ] Single project deployment on Vercel
- [ ] Improved build times and bundle sizes
- [ ] Enhanced developer experience with shared tooling

## Next Steps

1. **Stakeholder Approval**: Review and approve this consolidation plan
2. **Resource Allocation**: Assign developers for each phase
3. **Setup Development Environment**: Create monorepo structure
4. **Begin Phase 1**: Start with UI component extraction
5. **Establish Testing Strategy**: Set up cross-project testing framework

---

*This plan serves as a living document and will be updated based on implementation learnings and stakeholder feedback.*