import { createApp } from 'vue'
import CsvImportButton from '../components/CsvImportButton.vue'

document.addEventListener('DOMContentLoaded', () => {
  const csvImportApp = document.getElementById('csv-import-app')

  if (csvImportApp) {
    const app = createApp({
      components: {
        CsvImportButton
      }
    })

    app.mount('#csv-import-app')
  }
})
