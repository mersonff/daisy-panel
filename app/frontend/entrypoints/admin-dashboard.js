import { Chart, registerables } from 'chart.js'

Chart.register(...registerables)

document.addEventListener('DOMContentLoaded', () => {
  initClientsChart()
  initAppointmentsChart()
})

async function initClientsChart() {
  const chartContainer = document.getElementById('clientsChart')
  if (!chartContainer) {
    return
  }

  chartContainer.innerHTML = 'Carregando gráfico...'

  try {
    const response = await fetch('/admin/dashboard/clients_chart_data')
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }

    const data = await response.json()

    const canvas = document.createElement('canvas')
    canvas.style.maxHeight = '256px'
    canvas.style.width = '100%'

    chartContainer.innerHTML = ''
    chartContainer.appendChild(canvas)

    new Chart(canvas, {
      type: 'line',
      data: {
        labels: data.labels,
        datasets: [{
          label: 'Clientes Cadastrados',
          data: data.values,
          borderColor: '#570df8',
          backgroundColor: 'rgba(87, 13, 248, 0.1)',
          borderWidth: 2,
          fill: true,
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: 1
            }
          }
        }
      }
    })
  } catch (error) {
    console.error('Erro ao carregar gráfico:', error)
    chartContainer.innerHTML = '<div class="flex items-center justify-center h-full text-error">Erro ao carregar gráfico: ' + error.message + '</div>'
  }
}

async function initAppointmentsChart() {
  const chartContainer = document.getElementById('appointmentsChart')
  if (!chartContainer) {
    return
  }

  chartContainer.innerHTML = 'Carregando gráfico...'

  try {
    const response = await fetch('/admin/dashboard/appointments_data')
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }

    const data = await response.json()

    const canvas = document.createElement('canvas')
    canvas.style.maxHeight = '256px'
    canvas.style.width = '100%'

    chartContainer.innerHTML = ''
    chartContainer.appendChild(canvas)

    new Chart(canvas, {
      type: 'line',
      data: {
        labels: data.labels,
        datasets: [{
          label: 'Compromissos Criados',
          data: data.values,
          borderColor: '#f59e0b',
          backgroundColor: 'rgba(245, 158, 11, 0.1)',
          borderWidth: 2,
          fill: true,
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: 1
            }
          }
        }
      }
    })
  } catch (error) {
    chartContainer.innerHTML = '<div class="flex items-center justify-center h-full text-error">Erro ao carregar gráfico: ' + error.message + '</div>'
  }
}
