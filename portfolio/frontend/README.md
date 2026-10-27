# README

## Runtime

- NodeJs: v24.14.1
- NPM

## Tech Stack

- React
- Typescript

## Dependencies

- Tailwind - CSS
- Lucid react - Icon
- Shadcn - Reusable components
- Recharts

## Setup and Install

### Node

```sh
node -v
```

```sh
npm -v
```

### React

```sh
npm create vite@latest ./portfolio-dashboard -- --template react-ts
```

### Lucide React

```sh
cd ./portfolio-dashboard && npm install lucide-react
```

### Tailwind

[Tailwind Installation Guide](https://tailwindcss.com/docs/installation/using-vite)

```sh
npm install tailwindcss @tailwindcss/vite
```

**Configure Tailwind:**

```ts
import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
})
```

**tsconfig.json:** Add compiler option

```ts

  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
```

**vite.config.ts:**

```ts
import path from "path"

...
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
```

### shadcn

[shadcn](https://ui.shadcn.com/docs/installation/vite)

```sh
npx shadcn@latest init
```

**Adding a component:**

```sh
npx shadcn@latest add button
```

### Recharts

```sh
npm install recharts
```

## Run React

```sh
cd frontend/v1 && npm run dev
```


## Troubleshooting

Error after executing

```sh
npm create vite@latest ./portfolio-dashboard -- --template react-ts
```

```txt
│
◇  Installing dependencies with npm...
npm error code ERESOLVE
npm error ERESOLVE unable to resolve dependency tree
npm error
npm error While resolving: portfolio-dashboard@0.0.0
npm error Found: typescript@7.0.2
npm error node_modules/typescript
npm error   dev typescript@"~7.0.2" from the root project
npm error
npm error Could not resolve dependency:
npm error peer typescript@">=4.8.4 <6.1.0" from typescript-eslint@8.72.1
npm error node_modules/typescript-eslint
npm error   dev typescript-eslint@"^8.72.0" from the root project
npm error
npm error Fix the upstream dependency conflict, or retry this command with --force or --legacy-peer-deps to accept an incorrect (and potentially broken) dependency resolution.
npm error
npm error
npm error For a full report see:
npm error /Users/kunmi/.npm/_logs/2026-10-27T20_05_12_442Z-eresolve-report.txt
npm error A complete log of this run can be found in: /Users/kunmi/.npm/_logs/2026-10-27T20_05_12_442Z-debug-0.log
npm error code 1
npm error path /Users/kunmi/workspace/projects/engineering/repository/portfolio-platform/portfolio/frontend
npm error command failed
npm error command sh -c 'cva' ./portfolio-dashboard --template react-ts
npm error A complete log of this run can be found in: /Users/kunmi/.npm/_logs/2026-10-27T20_05_07_366Z-debug-0.log
```

## Fix

- Downgrade typescript

**Edit:** `package.json`

from `"typescript": "~7.0.2"` to `"typescript": "~5.9.3"`
