# Daisy Panel

Sistema completo de gerenciamento de clientes desenvolvido com Rails 8, Hotwire/Turbo e DaisyUI.

## 🚀 Funcionalidades

- **CRUD Completo de Clientes**: Criar, visualizar, editar e excluir clientes
- **Validações Robustas**: CPF, CEP, telefone e estados brasileiros
- **Busca Avançada**: Por nome, CPF ou telefone com filtros
- **Interface Responsiva**: Funciona em desktop e mobile
- **Máscaras Automáticas**: CPF, telefone e CEP com Stimulus
- **Autenticação**: Sistema completo com Devise

## 🛠️ Tecnologias

- **Ruby 3.3.8**
- **Rails 8.0.2**
- **PostgreSQL**
- **Hotwire/Turbo**
- **Stimulus**
- **DaisyUI + TailwindCSS**
- **RSpec + Capybara**
- **Pagy (Paginação)**

## ⚙️ Configuração

### 1. Clone o repositório
```bash
git clone https://github.com/mersonff/daisy-panel.git
cd daisy-panel
```

### 2. Instale as dependências
```bash
bundle install
```

### 3. Configure as variáveis de ambiente
```bash
cp .env.example .env
```

Edite o arquivo `.env` e configure:
- `DEVISE_SECRET_KEY`: Gere com `rails secret`
- `DATABASE_URL`: URL do PostgreSQL
- `POSTGRES_PASSWORD`: Senha do PostgreSQL

### 4. Configure o banco de dados
```bash
rails db:setup
```

### 5. Execute os testes
```bash
bundle exec rspec
```

### 6. Inicie o servidor
```bash
foreman start -f Procfile.dev
```

## 🐳 Docker (Desenvolvimento)

Para executar o projeto usando Docker:

### 1. Clone o repositório
```bash
git clone https://github.com/mersonff/daisy-panel.git
cd daisy-panel
```

### 2. Configure as variáveis de ambiente
```bash
cp .env.example .env
```

**Edite o arquivo `.env` e configure:**
- `DATABASE_URL`: Use `postgresql://postgres:postgres@db:5432/daisy_panel_development`
- `DEVISE_SECRET_KEY`: Gere uma chave com `docker-compose run --rm web bundle exec rails secret`

### 3. Execute com Docker Compose
```bash
# Construir e iniciar todos os serviços
docker-compose up --build

# Executar em background
docker-compose up -d --build
```

### 4. Configure o banco de dados (primeira execução)
```bash
# Criar e popular o banco
docker-compose exec web bundle exec rails db:setup

# Ou, se já existir:
docker-compose exec web bundle exec rails db:migrate
docker-compose exec web bundle exec rails db:seed
```

### 5. Acesse a aplicação
- **Aplicação**: http://localhost:3000
- **PostgreSQL**: localhost:5432

### Comandos úteis do Docker
```bash
# Ver logs
docker-compose logs -f

# Executar comandos no container
docker-compose exec web bundle exec rails console
docker-compose exec web bundle exec rspec

# Parar os serviços
docker-compose down

# Rebuild completo
docker-compose down -v
docker-compose up --build
```

## 🧪 Testes

O projeto possui **100% de cobertura de testes** com **196 testes**:

```bash
# Executar todos os testes
bundle exec rspec

# Executar testes específicos
bundle exec rspec spec/models/
bundle exec rspec spec/features/
```

## 🔧 GitHub Actions

O projeto possui CI/CD configurado com:
- **Análise de segurança** (Brakeman)
- **Verificação de código** (RuboCop)
- **Execução de testes** (RSpec)

### Configuração de Secrets

Adicione no GitHub Secrets:
- `DEVISE_SECRET_KEY`: Chave secreta do Devise

## 📱 Interface

- **Layout responsivo** com DaisyUI
- **Tema dark/light** automático
- **Navegação intuitiva**
- **Feedback visual** em português

## 🌐 Aplicação em Produção

A aplicação está rodando em produção na AWS:
**https://daisy-panel-alb-1719230918.us-east-1.elb.amazonaws.com**

### Credenciais de Admin
- Email: `admin@daisypanel.com`
- Senha: `password`

## 🔧 Dados Iniciais (Seed)

Para popular o banco com dados de exemplo:

```bash
rails db:seed
```

Isso criará:
- Usuário admin com as credenciais acima
- 35 clientes de exemplo
- Alguns compromissos de teste

## 🚀 Deploy

O projeto está configurado para deploy na AWS ECS Fargate com Load Balancer e SSL.

---

**Desenvolvido com ❤️ usando Rails 8**
