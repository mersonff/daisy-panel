import { createConsumer } from '@rails/actioncable'

const cable = createConsumer()

function updateStats(data) {
  document.getElementById('total-clients').textContent = data.total_clients || 0
  document.getElementById('duplicate-phones').textContent = data.duplicate_phones || 0

  const stateTableBody = document.getElementById('clients-per-state')
  stateTableBody.innerHTML = ''

  if (data.clients_by_state) {
    Object.entries(data.clients_by_state).forEach(([state, count]) => {
      const row = `<tr><td>${state}</td><td>${count}</td></tr>`
      stateTableBody.innerHTML += row
    })
  }
}

document.addEventListener('DOMContentLoaded', () => {
  cable.subscriptions.create('PublicDashboardChannel', {
    connected() {
    },

    disconnected() {
    },

    received(data) {
      if (data.type === 'stats_update') {
        updateStats(data.data)
      } else if (data.type === 'initial_stats') {
        updateStats(data.data)
      }
    }
  })
})
