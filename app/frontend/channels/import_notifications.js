import { createConsumer } from "@rails/actioncable"

class ImportNotifications {
  constructor() {
    console.log("🏗️ Construindo ImportNotifications...")
    // Use a URL padrão do ActionCable (mesmo servidor Rails)
    this.consumer = createConsumer()
    this.subscription = null
    
    // Pegar user ID da meta tag
    const userMeta = document.querySelector('meta[name="current-user"]')
    this.userId = userMeta ? userMeta.content : null
    console.log("👤 User ID encontrado:", this.userId)
    
    this.connect()
  }

  connect() {
    if (!this.userId) {
      console.error("❌ Não foi possível obter user ID - não conectando ao canal")
      return
    }

    console.log(`📡 Conectando ao canal para o usuário ${this.userId}...`)

    this.subscription = this.consumer.subscriptions.create("ImportNotificationsChannel", {
      // Usando arrow functions para manter o contexto do `this`
      connected: () => {
        console.log(`✅ Conectado ao ImportNotificationsChannel para o usuário ${this.userId}`)
      },

      disconnected: () => {
        console.log("❌ Desconectado do ImportNotificationsChannel")
      },

      received: (data) => {
        console.log("📨 Notificação recebida:", data)
        this.handleNotification(data)
      }
    })
  }

  handleNotification(data) {
    console.log("🔄 Processando notificação:", data)
    
    // Mostrar toast de notificação
    this.showToast(data)
    
    // Se estivermos na página de clientes, recarregar a lista
    if (window.location.pathname.includes('/admin/clients')) {
      this.refreshClientsList()
    }
  }

  showToast(data) {
    // Criar elemento de toast com styling melhorado
    const toast = document.createElement('div')
    toast.style.cssText = `
      position: fixed; 
      top: 20px; 
      right: 20px; 
      z-index: 9999; 
      max-width: 400px;
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
      border-radius: 8px;
      overflow: hidden;
    `
    
    // Definir cor baseada no tipo
    const bgColor = data.type === 'import_completed' 
      ? (data.error_count > 0 ? '#f59e0b' : '#10b981')  // amarelo se houver erros, verde se tudo ok
      : data.type === 'import_failed' ? '#ef4444' : '#3b82f6'  // vermelho para falha, azul para outros
    
    const icon = data.type === 'import_completed'
      ? (data.error_count > 0 ? '⚠️' : '✅')
      : data.type === 'import_failed' ? '❌' : 'ℹ️'
    
    const linkText = data.import_report_id ? 
      `<a href="/admin/import_reports/${data.import_report_id}" style="color: white; text-decoration: underline; margin-left: 8px;" onclick="event.stopPropagation();">Ver detalhes</a>` : 
      ''
    
    toast.innerHTML = `
      <div style="background: ${bgColor}; color: white; padding: 16px;">
        <div style="display: flex; align-items: flex-start; justify-content: space-between;">
          <div style="flex: 1;">
            <div style="display: flex; align-items: center;">
              <span style="font-size: 18px; margin-right: 8px;">${icon}</span>
              <strong>Importação CSV</strong>
            </div>
            <div style="margin-top: 4px; font-size: 14px;">
              ${(data.message || 'Processamento concluído').replace(/\\(.)/g, '$1')}
              ${linkText}
            </div>
          </div>
          <button onclick="this.parentElement.parentElement.remove()" 
                  style="background: none; border: none; color: white; font-size: 20px; cursor: pointer; line-height: 1; padding: 0; margin-left: 8px;">×</button>
        </div>
      </div>
    `
    
    document.body.appendChild(toast)
    
    // Remover automaticamente após 10 segundos
    setTimeout(() => {
      if (toast.parentElement) {
        toast.remove()
      }
    }, 10000)
  }

  getAlertClass(type) {
    switch(type) {
      case 'import_completed':
        return 'alert-success'
      case 'import_failed':
        return 'alert-error'
      default:
        return 'alert-info'
    }
  }

  getIcon(type) {
    switch(type) {
      case 'import_completed':
        return `<svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>`
      case 'import_failed':
        return `<svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>`
      default:
        return `<svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>`
    }
  }

  refreshClientsList() {
    // Se estivermos na página de clientes, recarregar após um breve delay
    setTimeout(() => {
      if (window.location.pathname.includes('/admin/clients') && 
          !window.location.pathname.includes('/admin/clients/')) {
        window.location.reload()
      }
    }, 2000)
  }

  disconnect() {
    console.log("🔌 Desconectando ImportNotifications...")
    if (this.subscription) {
      console.log("📤 Unsubscribing da subscription")
      this.subscription.unsubscribe()
      this.subscription = null
    } else {
      console.log("⚠️ Nenhuma subscription ativa para desconectar")
    }
  }
}

// Singleton pattern para garantir apenas uma instância
class ImportNotificationsSingleton {
  constructor() {
    if (ImportNotificationsSingleton.instance) {
      return ImportNotificationsSingleton.instance
    }
    
    console.log("🏗️ Criando única instância de ImportNotifications...")
    this.notifications = new ImportNotifications()
    ImportNotificationsSingleton.instance = this
  }
  
  getInstance() {
    return this.notifications
  }
  
  static reset() {
    if (ImportNotificationsSingleton.instance) {
      console.log("🧹 Resetando singleton...")
      ImportNotificationsSingleton.instance.notifications.disconnect()
      ImportNotificationsSingleton.instance = null
    }
  }
}

// Função para inicializar as notificações
function initializeImportNotifications() {
  console.log("🔄 initializeImportNotifications called")
  
  // Reset completo
  ImportNotificationsSingleton.reset()
  
  // Criar nova instância singleton
  const singleton = new ImportNotificationsSingleton()
  window.importNotificationsInstance = singleton.getInstance()
}

// Prevenir múltiplas execuções
let isInitialized = false

// Event listener único
function setupEventListeners() {
  if (isInitialized) {
    console.log("⚠️ Event listeners já configurados")
    return
  }
  
  console.log("⚡ Configurando event listeners...")
  
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeImportNotifications, { once: true })
  } else {
    initializeImportNotifications()
  }
  
  // Turbo navigation - SEM re-inicializar no render
  document.addEventListener('turbo:before-render', () => {
    console.log("🔄 Turbo before render - cleaning up")
    ImportNotificationsSingleton.reset()
  }, { once: false })
  
  // REMOVIDO - não reinicializar no turbo:render
  
  isInitialized = true
}

// Executar setup
setupEventListeners()

export default ImportNotifications
