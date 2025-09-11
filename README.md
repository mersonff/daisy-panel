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
