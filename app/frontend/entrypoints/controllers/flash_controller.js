import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['message']
  static values = { autohide: { type: Number, default: 5000 } }

  connect() {
    if (this.autohideValue > 0) {
      setTimeout(() => {
        this.hide()
      }, this.autohideValue)
    }
  }

  close() {
    this.hide()
  }

  hide() {
    const element = this.element
    element.style.transition = 'opacity 0.3s ease-out, transform 0.3s ease-out'
    element.style.opacity = '0'
    element.style.transform = 'translateY(-100%)'

    setTimeout(() => {
      if (element.parentNode) {
        element.remove()
        this.updateMainPadding()
      }
    }, 300)
  }

  updateMainPadding() {
    setTimeout(() => {
      const remainingFlashes = document.querySelectorAll('[data-controller*="flash"]:not([style*="opacity: 0"])')
      const mainElement = document.getElementById('main-content')

      if (remainingFlashes.length === 0 && mainElement) {
        mainElement.classList.remove('pt-16')
      }
    }, 100)
  }
}
