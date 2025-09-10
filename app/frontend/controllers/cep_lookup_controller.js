import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['address', 'city', 'state']

  connect() {
    this.maskCep()
  }

  maskCep() {
    this.element.addEventListener('input', (event) => {
      let value = event.target.value.replace(/\D/g, '')

      if (value.length <= 8) {
        value = value.replace(/(\d{5})(\d)/, '$1-$2')
      }

      event.target.value = value

      if (value.replace(/\D/g, '').length === 8) {
        this.fetchAddress(value.replace(/\D/g, ''))
      }
    })
  }

  async fetchAddress(cep) {
    try {
      const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`)
      const data = await response.json()

      if (!data.erro) {
        const addressField = document.getElementById('client_address')
        const cityField = document.getElementById('client_city')
        const stateField = document.getElementById('client_state')

        if (addressField && data.logradouro) {
          addressField.value = `${data.logradouro}${data.bairro ? ', ' + data.bairro : ''}`
        }
        if (cityField && data.localidade) {
          cityField.value = data.localidade
        }
        if (stateField && data.uf) {
          stateField.value = data.uf
        }
      }
    } catch (error) {
      console.error('Erro ao buscar CEP:', error)
    }
  }
}
