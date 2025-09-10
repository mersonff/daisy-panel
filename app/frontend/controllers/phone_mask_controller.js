import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.maskPhone()
  }

  maskPhone() {
    this.element.addEventListener('input', (event) => {
      let value = event.target.value.replace(/\D/g, '')

      if (value.length <= 11) {
        if (value.length <= 10) {
          value = value.replace(/(\d{2})(\d)/, '($1) $2')
          value = value.replace(/(\d{4})(\d)/, '$1-$2')
        } else {
          value = value.replace(/(\d{2})(\d)/, '($1) $2')
          value = value.replace(/(\d{5})(\d)/, '$1-$2')
        }
      }

      event.target.value = value
    })
  }
}
