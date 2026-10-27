# README

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
npm create vite@latest ./frontend/v1 -- --template react-ts
```

**Install Lucide React:**

```sh
cd frontend/v1 && npm install lucide-react
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

**tsconfig.json:**

Add compileropton

```ts

  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
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

## Run React

```sh
cd frontend/v1 && npm run dev
```
