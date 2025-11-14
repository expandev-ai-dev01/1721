# LoveCakes Frontend

Interface de compra e venda de bolos artesanais.

## Tecnologias

- React 19.2.0
- TypeScript 5.6.3
- Vite 5.4.11
- TailwindCSS 3.4.14
- React Router 7.9.3
- TanStack Query 5.90.2
- Zustand 5.0.8

## Estrutura do Projeto

```
src/
├── app/              # Configuração da aplicação
├── pages/            # Páginas e layouts
├── domain/           # Domínios de negócio
├── core/             # Componentes e utilitários compartilhados
└── assets/           # Recursos estáticos
```

## Comandos

```bash
# Instalar dependências
npm install

# Desenvolvimento
npm run dev

# Build
npm run build

# Preview
npm run preview

# Lint
npm run lint
```

## Variáveis de Ambiente

Crie um arquivo `.env` baseado no `.env.example`:

```
VITE_API_URL=http://localhost:3000
VITE_API_VERSION=v1
VITE_API_TIMEOUT=30000
```