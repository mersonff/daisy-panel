// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>

// Example: Load Rails libraries in Vite.
import * as Turbo from '@hotwired/turbo'
Turbo.start()

import { Application } from '@hotwired/stimulus'
import { registerControllers } from 'stimulus-vite-helpers'

const application = Application.start()
const controllers = import.meta.glob('../controllers/*_controller.js', { eager: true })
registerControllers(application, controllers)

import { createApp } from 'vue'
import CsvImportButton from '../components/CsvImportButton.vue'
import '../channels/import_notifications.js'

let vueApp = null

function mountVueApp() {

  const csvImportApp = document.getElementById('csv-import-app')

  if (csvImportApp && !vueApp) {

    try {
      vueApp = createApp(CsvImportButton)
      vueApp.mount('#csv-import-app')
    } catch (error) {
      console.error('Vue mount error:', error)
    }

  }
}

function unmountVueApp() {
  if (vueApp) {
    vueApp.unmount()
    vueApp = null
  }
}

document.addEventListener('DOMContentLoaded', mountVueApp)
document.addEventListener('turbo:before-visit', unmountVueApp)
document.addEventListener('turbo:load', mountVueApp)

// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
