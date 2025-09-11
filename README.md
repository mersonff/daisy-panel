# Daisy Panel 🌼

Sistema completo de gerenciamento de clientes e compromissos desenvolvido com Rails 8, Hotwire/Turbo e DaisyUI.

## 🚀 Funcionalidades

### Gerenciamento de Clientes
- **CRUD Completo**: Criar, visualizar, editar e excluir clientes
- **Importação CSV**: Upload e processamento assíncrono de arquivos CSV
- **Validações Robustas**: CPF, CEP, telefone e estados brasileiros
- **Busca Avançada**: Por nome, CPF ou telefone com filtros
- **Dashboard**: Gráficos e métricas em tempo real

### Gerenciamento de Compromissos
- **Agendamento**: Criar compromissos associados a clientes
- **Validação de conflitos**: Evita sobreposição de horários
- **Visualização**: Lista e detalhamento de compromissos

### Interface e Experiência
- **Interface Responsiva**: Funciona em desktop e mobile
- **Máscaras Automáticas**: CPF, telefone e CEP com Stimulus
- **Autenticação**: Sistema completo com Devise
- **Feedback em Tempo Real**: ActionCable para atualizações instantâneas
- **Processamento Assíncrono**: Jobs em background com Solid Queue

## 🛠️ Tecnologias

### Backend
- **Ruby 3.3.8**
- **Rails 8.0.2**
- **PostgreSQL** (banco principal)
- **Solid Queue** (jobs assíncronos)
- **Solid Cable** (WebSockets)
- **Solid Cache** (cache)

### Frontend
- **Hotwire/Turbo**
- **Stimulus**
- **DaisyUI + TailwindCSS**
- **Chart.js** (gráficos)
- **Vite** (build assets)

### Testes e Deploy
- **RSpec + Capybara**
- **Pagy** (paginação)
- **Docker** (containerização)
- **AWS ECS Fargate** (produção)

## ⚙️ Desenvolvimento Local

### Opção 1: Sem Docker

#### 1. Clone o repositório
```bash
git clone https://github.com/mersonff/daisy-panel.git
cd daisy-panel
```

#### 2. Instale as dependências
```bash
# Ruby dependencies
bundle install

# Node.js dependencies
npm install
```

#### 3. Configure o banco PostgreSQL
Certifique-se que o PostgreSQL está rodando localmente. O arquivo `.env` já está configurado:

```bash
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/daisy_panel_development
```

Se precisar de credenciais diferentes, edite o `.env`:
```bash
DATABASE_URL=postgresql://seu_usuario:sua_senha@localhost:5432/daisy_panel_development
```

#### 4. Configure o banco de dados
```bash
rails db:setup
```

#### 5. Inicie os serviços
```bash
# Em terminais separados:

# 1. Rails server
foreman start -f Procfile.dev

# 2. Solid Queue (jobs assíncronos)
rails solid_queue:start
```

### Opção 2: Com Docker (Recomendado)

#### 1. Clone o repositório
```bash
git clone https://github.com/mersonff/daisy-panel.git
cd daisy-panel
```

#### 2. Suba os containers
```bash
# Subir todos os serviços (web + db + worker)
docker-compose up

# Ou em background
docker-compose up -d
```

#### 3. Configure o banco (primeira vez)
```bash
docker-compose run web bundle exec rails db:migrate db:seed
```

#### 4. Acesse a aplicação
```
http://localhost:3000
```

**Usuário admin:**
- Email: `admin@daisypanel.com`
- Senha: `password`

## 🧪 Executar Testes

### Sem Docker
```bash
# Todos os testes
bundle exec rspec

# Testes específicos
bundle exec rspec spec/models/
bundle exec rspec spec/features/
bundle exec rspec spec/requests/

# Com cobertura
COVERAGE=true bundle exec rspec
```

### Com Docker
```bash
# Todos os testes
docker-compose run web bundle exec rspec

# Testes específicos
docker-compose run web bundle exec rspec spec/models/
```

## 🌐 Aplicação em Produção

A aplicação está rodando em produção na AWS:
**https://daisy-panel-alb-1234567890.us-east-1.elb.amazonaws.com**

### Credenciais de Admin
- Email: `admin@daisypanel.com`
- Senha: `password`

## 🔧 Primeiro Setup

### Configurar dados iniciais
```bash
# Sem Docker
rails db:seed

# Com Docker
docker-compose run web bundle exec rails db:seed
```

Isso criará:
- Usuário admin com as credenciais acima
- 35 clientes de exemplo
- Alguns compromissos de teste

## 📊 Funcionalidades Avançadas

### Importação CSV
1. Acesse **Admin > Import CSV**
2. Faça upload de arquivo com colunas: `name,phone,cpf,address,city,state,postal_code`
3. O processamento é feito em background
4. Acompanhe o progresso em tempo real

### Dashboard com Métricas
- Gráfico de clientes cadastrados por período
- Gráfico de compromissos criados
- Estatísticas atualizadas em tempo real

### WebSockets (ActionCable)
- Atualizações automáticas no dashboard
- Feedback instantâneo de operações

