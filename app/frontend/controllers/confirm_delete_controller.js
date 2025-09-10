import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    itemName: String,
    itemType: String,
    confirmText: String,
    additionalInfo: String
  }

  connect() {
    console.log("Confirm delete controller connected")
    // Intercepta o submit do formulário
    this.element.addEventListener('submit', this.handleSubmit.bind(this))
  }

  handleSubmit(event) {
    console.log("Form submit intercepted")
    // Previne o submit padrão
    event.preventDefault()
    
    // Atualiza o modal com os dados do item
    const itemNameElement = document.getElementById('delete_item_name')
    const itemTypeElement = document.getElementById('delete_item_type')
    const confirmTextElement = document.getElementById('confirm_delete_text')
    const additionalInfoElement = document.getElementById('delete_additional_info')
    
    if (itemNameElement) {
      itemNameElement.textContent = this.itemNameValue || 'o item'
    }
    
    if (itemTypeElement) {
      itemTypeElement.textContent = this.itemTypeValue || 'o item'
    }
    
    if (confirmTextElement) {
      confirmTextElement.textContent = this.confirmTextValue || 'Sim, Remover'
    }
    
    if (additionalInfoElement) {
      additionalInfoElement.textContent = this.additionalInfoValue || 'Todos os dados relacionados serão permanentemente excluídos.'
    }
    
    // Armazena o formulário para submit posterior
    this.formToSubmit = event.target
    
    // Configura o botão de confirmação
    const confirmBtn = document.getElementById('confirm_delete_btn')
    if (confirmBtn) {
      confirmBtn.onclick = this.confirmDelete.bind(this)
    }
    
    // Abre o modal
    const modal = document.getElementById('delete_confirmation_modal')
    if (modal) {
      modal.showModal()
    }
  }

  confirmDelete() {
    console.log("Delete confirmed")
    // Fecha o modal
    const modal = document.getElementById('delete_confirmation_modal')
    if (modal) {
      modal.close()
    }
    
    // Submete o formulário original
    if (this.formToSubmit) {
      this.formToSubmit.submit()
    }
  }
}
