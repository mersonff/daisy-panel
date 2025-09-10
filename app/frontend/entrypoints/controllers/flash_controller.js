import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]
  static values = { autohide: { type: Number, default: 5000 } }

  connect() {
    console.log("Flash controller connected")
    
    // Auto-hide after specified time
    if (this.autohideValue > 0) {
      setTimeout(() => {
        this.hide()
      }, this.autohideValue)
    }
  }

  close() {
    console.log("Closing flash message")
    this.hide()
  }

  hide() {
    const element = this.element
    element.style.transition = "opacity 0.3s ease-out, transform 0.3s ease-out"
    element.style.opacity = "0"
    element.style.transform = "translateY(-100%)"
    
    setTimeout(() => {
      if (element.parentNode) {
        element.remove()
        this.updateMainPadding()
      }
    }, 300)
  }

  updateMainPadding() {
    // Wait a bit to ensure the element is fully removed from DOM
    setTimeout(() => {
      // Check if there are any remaining visible flash messages
      const remainingFlashes = document.querySelectorAll('[data-controller*="flash"]:not([style*="opacity: 0"])')
      const mainElement = document.getElementById('main-content')
      
      console.log("Remaining flashes:", remainingFlashes.length)
      
      if (remainingFlashes.length === 0 && mainElement) {
        // Remove padding if no flash messages remain
        mainElement.classList.remove('pt-16')
        console.log("Removed pt-16 from main content")
      }
    }, 100)
  }
}
