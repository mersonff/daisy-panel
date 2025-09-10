import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { pattern: String }

  connect() {
    this.element.addEventListener('input', this.maskInput.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('input', this.maskInput.bind(this))
  }

  maskInput(event) {
    const pattern = this.patternValue
    const value = event.target.value.replace(/\D/g, '')

    if (!pattern) {
      return
    }

    let maskedValue = ''
    let valueIndex = 0

    for (let i = 0; i < pattern.length && valueIndex < value.length; i++) {
      if (pattern[i] === '0') {
        maskedValue += value[valueIndex]
        valueIndex++
      } else {
        maskedValue += pattern[i]
      }
    }

    event.target.value = maskedValue
  }
}
