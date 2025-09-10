import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    itemName: String,
    itemType: String,
    confirmText: String,
    additionalInfo: String
  }

  connect() {
    this.element.addEventListener('submit', this.handleSubmit.bind(this))
  }

  handleSubmit(event) {
    event.preventDefault()

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

    this.formToSubmit = event.target

    const confirmBtn = document.getElementById('confirm_delete_btn')
    if (confirmBtn) {
      confirmBtn.onclick = this.confirmDelete.bind(this)
    }

    const modal = document.getElementById('delete_confirmation_modal')
    if (modal) {
      modal.showModal()
    }
  }

  confirmDelete() {
    const modal = document.getElementById('delete_confirmation_modal')
    if (modal) {
      modal.close()
    }

    if (this.formToSubmit) {
      this.formToSubmit.submit()
    }
  }
}
