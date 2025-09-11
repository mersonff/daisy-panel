<template>
  <div id="clientsChart" class="h-64" />
</template>

<script>
import { Chart, registerables } from 'chart.js'

Chart.register(...registerables)

export default {
  name: 'ClientsChart',
  props: {
    data: {
      type: Object,
      default: () => ({})
    }
  },
  mounted() {
    this.initChart()
  },
  methods: {
    async initChart() {
      try {
        const response = await fetch('/admin/dashboard/clients_chart_data')
        const chartData = await response.json()

        this.createChart(chartData)
      } catch (error) {
        console.error('Erro ao carregar dados do gráfico:', error)
        this.showError()
      }
    },
    createChart(data) {
      const ctx = document.getElementById('clientsChart')

      new Chart(ctx, {
        type: 'line',
        data: {
          labels: data.labels,
          datasets: [{
            label: 'Clientes Cadastrados',
            data: data.values,
            borderColor: 'hsl(var(--p))',
            backgroundColor: 'hsl(var(--p) / 0.1)',
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
    },
    showError() {
      const container = document.getElementById('clientsChart')
      container.innerHTML = '<div class="flex items-center justify-center h-full text-error">Erro ao carregar gráfico</div>'
    }
  }
}
</script>
