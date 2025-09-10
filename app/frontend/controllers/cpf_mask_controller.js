import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.maskCpf()
  }

  maskCpf() {
    this.element.addEventListener('input', (event) => {
      let value = event.target.value.replace(/\D/g, '')
      
      if (value.length <= 11) {
        value = value.replace(/(\d{3})(\d)/, '$1.$2')
        value = value.replace(/(\d{3})(\d)/, '$1.$2')
        value = value.replace(/(\d{3})(\d{1,2})$/, '$1-$2')
      }
      
      event.target.value = value
    })
  }
}
