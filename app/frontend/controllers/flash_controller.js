import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { autohide: Number }

  connect() {
    if (this.hasAutohideValue && this.autohideValue > 0) {
      this.timeout = setTimeout(() => {
        this.close()
      }, this.autohideValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  close() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.element.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out'
    this.element.style.opacity = '0'
    this.element.style.transform = 'translateY(-20px)'

    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
