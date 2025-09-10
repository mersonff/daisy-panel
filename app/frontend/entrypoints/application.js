// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// Example: Load Rails libraries in Vite.
import * as Turbo from '@hotwired/turbo'
Turbo.start()

import { Application } from '@hotwired/stimulus'
import { registerControllers } from 'stimulus-vite-helpers'

const application = Application.start()
const controllers = import.meta.glob('../controllers/*_controller.js', { eager: true })
registerControllers(application, controllers)

// CSV Import with Vue 3
import { createApp } from 'vue'
import CsvImportButton from '../components/CsvImportButton.vue'

// Import notifications
import '../channels/import_notifications.js'

let vueApp = null

function mountVueApp() {
  console.log('=== VUE DEBUG ===')
  console.log('Looking for csv-import-app...')
  
  const csvImportApp = document.getElementById('csv-import-app')
  console.log('Element found:', csvImportApp)
  
  if (csvImportApp && !vueApp) {
    console.log('Mounting Vue app...')
    
    try {
      // Use render function instead of template
      vueApp = createApp(CsvImportButton)
      vueApp.mount('#csv-import-app')
      console.log('Vue app mounted successfully!')
    } catch (error) {
      console.error('Vue mount error:', error)
    }
    
  } else if (csvImportApp && vueApp) {
    console.log('Vue app already mounted')
  } else {
    console.log('csv-import-app not found')
  }
}

function unmountVueApp() {
  if (vueApp) {
    console.log('Unmounting Vue app...')
    vueApp.unmount()
    vueApp = null
  }
}

// Mount on DOMContentLoaded
document.addEventListener('DOMContentLoaded', mountVueApp)

// Handle Turbo navigation
document.addEventListener('turbo:before-visit', unmountVueApp)
document.addEventListener('turbo:load', mountVueApp)

// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'
