# Template — infra de e2e (skill e2e)

Esqueletos canônicos dos artefatos que a skill e2e gera no projeto-alvo.
Regras: compose de e2e vive em `docker-compose.e2e.yml` na RAIZ do projeto;
specs Playwright vivem em `e2e/`; ambos são VERSIONADOS (commit junto da
demanda). Projeto com infra de e2e própria → estender o padrão existente,
nunca criar estrutura paralela.

## docker-compose.e2e.yml

```yaml
# Gerado pela skill e2e (audora-commander) — infra de teste, NÃO de produção.
# Preencher a partir da stack/Constituição do MEMORY. Todo serviço que o app
# espera precisa de healthcheck — o `up -d --wait` depende disso.
services:
  app:
    # build: .          # projeto com Dockerfile
    # image: node:22    # sem Dockerfile: imagem da stack + command de dev
    # command: npm run dev
    ports:
      - "3000:3000" # porta do como-rodar da Constituição
    environment:
      # envs mínimas de teste — segredo real NUNCA aqui; usar placeholder
      # e ler de .env local (ex.: DATABASE_URL apontando para o serviço db)
      DATABASE_URL: postgres://e2e:e2e@db:5432/e2e
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]
      interval: 5s
      timeout: 3s
      retries: 10

  db:
    # exemplo com Postgres — trocar pela dependência real da stack
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: e2e
      POSTGRES_PASSWORD: e2e
      POSTGRES_DB: e2e
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U e2e"]
      interval: 5s
      timeout: 3s
      retries: 10
    tmpfs:
      - /var/lib/postgresql/data # dado de teste é descartável — nada persiste
```

Subir: `docker compose -f docker-compose.e2e.yml up -d --wait`
Derrubar (teardown SEMPRE): `docker compose -f docker-compose.e2e.yml down`

## e2e/<id-da-demanda>.spec.ts (Playwright — projetos web)

```ts
// Gerado pela skill e2e (audora-commander) — cenário E2E da demanda <id>.
// 1 test() por critério EARS do nó; nome do test = o critério, verbatim.
import { test, expect } from '@playwright/test';

test.describe('<id-da-demanda>', () => {
  test('QUANDO <condição> O SISTEMA DEVE <comportamento>', async ({ page }) => {
    await page.goto('/');
    // montar a condição navegando/preenchendo como usuário real
    // assert no comportamento observável (tela), não em estado interno
    await expect(page.getByRole('heading')).toBeVisible();
  });
});
```

Sem Playwright no projeto (bootstrap mínimo, decisão registrada no nó):
`npm i -D @playwright/test && npx playwright install chromium`, e
`playwright.config.ts` com `use: { baseURL: 'http://localhost:3000' }`
(porta do compose acima).

<!-- Regras de preenchimento (skill e2e):
1. Serviços e envs saem da stack/Constituição do MEMORY — não inventar
   dependência que o projeto não declara.
2. Segredo real NUNCA entra no compose versionado — placeholder + .env.
3. Healthcheck em todo serviço; sem healthcheck o --wait não protege nada.
4. Specs: 1 test por critério EARS, incluindo os critérios de ERRO.
5. Artefato existente → estender; recriar do zero é red flag da skill. -->
