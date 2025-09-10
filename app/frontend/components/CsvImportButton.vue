<template>
  <div>
    <!-- Botão para abrir modal -->
    <button class="btn btn-outline btn-sm" @click="openModal">
      <svg
        class="w-4 h-4 mr-2"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
        />
      </svg>
      Importar CSV
    </button>

    <!-- Modal -->
    <div v-if="showModal" class="modal modal-open">
      <div class="modal-box">
        <h3 class="font-bold text-lg mb-4">
          Importar Clientes via CSV
        </h3>

        <!-- Área de upload -->
        <div class="form-control w-full mb-4">
          <label class="label">
            <span class="label-text">Selecione o arquivo CSV</span>
            <span class="label-text-alt">Formatos aceitos: .csv</span>
          </label>

          <!-- Drag and Drop Area -->
          <div
            :class="['border-2 border-dashed rounded-lg p-8 text-center transition-colors',
                     isDragging ? 'border-primary bg-primary/10' : 'border-gray-300']"
            @dragover.prevent="isDragging = true"
            @dragleave.prevent="isDragging = false"
            @drop.prevent="handleDrop"
          >
            <div v-if="!selectedFile">
              <svg
                class="mx-auto h-12 w-12 text-gray-400 mb-4"
                stroke="currentColor"
                fill="none"
                viewBox="0 0 48 48"
              >
                <path
                  d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
              </svg>
              <p class="text-gray-600 mb-2">
                Arraste seu arquivo CSV aqui ou
              </p>
              <button type="button" class="btn btn-outline btn-sm" @click="$refs.fileInput.click()">
                Selecionar arquivo
              </button>
              <p class="text-xs text-gray-500 mt-2">
                Colunas esperadas: Nome, CPF, Telefone, Endereço, Cidade, Estado, CEP
              </p>
            </div>

            <div v-else class="text-green-600">
              <svg
                class="mx-auto h-12 w-12 mb-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <p class="font-medium">
                {{ selectedFile.name }}
              </p>
              <p class="text-sm text-gray-500">
                {{ formatFileSize(selectedFile.size) }}
              </p>
              <button class="btn btn-ghost btn-xs mt-2" @click="selectedFile = null">
                Remover arquivo
              </button>
            </div>
          </div>

          <!-- Input file oculto -->
          <input
            ref="fileInput"
            type="file"
            accept=".csv"
            class="hidden"
            @change="handleFileSelect"
          >
        </div>

        <!-- Informações importantes -->
        <div class="alert alert-info mb-4">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            class="stroke-current shrink-0 w-6 h-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <div class="text-sm">
            <p><strong>Importante:</strong></p>
            <ul class="list-disc list-inside mt-1">
              <li>O arquivo será processado automaticamente</li>
              <li>Estados podem ser nomes completos (ex: "Maranhão" → "MA")</li>
              <li>Você receberá uma notificação quando terminar</li>
            </ul>
          </div>
        </div>

        <!-- Mensagem de status -->
        <div v-if="message" :class="['alert mb-4', messageType === 'success' ? 'alert-success' : 'alert-error']">
          <span>{{ message }}</span>
        </div>

        <!-- Botões de ação -->
        <div class="modal-action">
          <button class="btn btn-ghost" :disabled="isImporting" @click="closeModal">
            Cancelar
          </button>
          <button
            :disabled="!selectedFile || isImporting"
            class="btn btn-primary"
            @click="importCsv"
          >
            <span v-if="isImporting" class="loading loading-spinner loading-sm mr-2" />
            {{ isImporting ? 'Enviando...' : 'Importar Arquivo' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CsvImportButton',
  data() {
    return {
      showModal: false,
      selectedFile: null,
      isDragging: false,
      isImporting: false,
      message: '',
      messageType: 'error'
    }
  },
  methods: {
    openModal() {
      this.showModal = true
      this.selectedFile = null
      this.message = ''
    },

    closeModal() {
      this.showModal = false
      this.selectedFile = null
      this.message = ''
      this.isImporting = false
    },

    handleFileSelect(event) {
      const file = event.target.files[0]
      if (file && (file.type === 'text/csv' || file.name.endsWith('.csv'))) {
        this.selectedFile = file
        this.message = ''
      } else {
        this.showMessage('Por favor, selecione um arquivo CSV válido.', 'error')
      }
    },

    handleDrop(event) {
      this.isDragging = false
      const files = event.dataTransfer.files
      if (files.length > 0) {
        const file = files[0]
        if (file.type === 'text/csv' || file.name.endsWith('.csv')) {
          this.selectedFile = file
          this.message = ''
        } else {
          this.showMessage('Por favor, selecione um arquivo CSV válido.', 'error')
        }
      }
    },

    formatFileSize(bytes) {
      if (bytes === 0) {
        return '0 Bytes'
      }
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    },

    async importCsv() {
      if (!this.selectedFile) {
        this.showMessage('Por favor, selecione um arquivo CSV.', 'error')
        return
      }

      this.isImporting = true

      try {
        const formData = new FormData()
        formData.append('csv_file', this.selectedFile)

        const response = await fetch('/admin/clients/import_csv', {
          method: 'POST',
          headers: {
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
          },
          body: formData
        })

        const result = await response.json()

        if (response.ok) {
          this.showMessage('Importação iniciada! Você será notificado quando concluída.', 'success')
          setTimeout(() => {
            this.closeModal()
          }, 2000)
        } else {
          this.showMessage(result.error || 'Erro ao importar arquivo.', 'error')
        }

      } catch (error) {
        this.showMessage('Erro ao importar arquivo. Tente novamente.', error)
      } finally {
        this.isImporting = false
      }
    },

    showMessage(text, type) {
      this.message = text
      this.messageType = type
    }
  }
}
</script>
