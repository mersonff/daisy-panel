<template>
  <div id="appointmentsCalendar" class="h-64">
    <div class="calendar-grid">
      <div class="calendar-header">
        <button class="btn btn-sm btn-ghost" @click="previousMonth">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 19l-7-7 7-7"
            />
          </svg>
        </button>
        <h3 class="text-lg font-semibold">
          {{ currentMonthName }} {{ currentYear }}
        </h3>
        <button class="btn btn-sm btn-ghost" @click="nextMonth">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-4 w-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 5l7 7-7 7"
            />
          </svg>
        </button>
      </div>

      <div class="grid grid-cols-7 gap-1 text-center text-xs">
        <div v-for="day in weekDays" :key="day" class="p-1 font-medium text-base-content/60">
          {{ day }}
        </div>
      </div>

      <div class="grid grid-cols-7 gap-1 text-center text-xs">
        <div
          v-for="date in calendarDays"
          :key="date.key"
          :class="[
            'p-1 h-8 flex items-center justify-center relative',
            {
              'text-base-content/40': !date.isCurrentMonth,
              'bg-primary text-primary-content rounded': date.isToday,
              'bg-secondary/20 rounded': date.hasAppointments && !date.isToday
            }
          ]"
        >
          {{ date.day }}
          <div
            v-if="date.hasAppointments"
            class="absolute bottom-0 right-0 w-1 h-1 bg-accent rounded-full"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AppointmentsCalendar',
  data() {
    return {
      currentDate: new Date(),
      appointments: [],
      weekDays: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
    }
  },
  computed: {
    currentYear() {
      return this.currentDate.getFullYear()
    },
    currentMonth() {
      return this.currentDate.getMonth()
    },
    currentMonthName() {
      const months = [
        'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
        'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
      ]
      return months[this.currentMonth]
    },
    calendarDays() {
      const firstDay = new Date(this.currentYear, this.currentMonth, 1)
      const startDate = new Date(firstDay)
      startDate.setDate(startDate.getDate() - firstDay.getDay())

      const days = []
      const today = new Date()

      for (let i = 0; i < 42; i++) {
        const date = new Date(startDate)
        date.setDate(startDate.getDate() + i)

        const dayStr = date.toISOString().split('T')[0]
        const hasAppointments = this.appointments.some(apt =>
          apt.start_time.startsWith(dayStr)
        )

        days.push({
          key: `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`,
          day: date.getDate(),
          isCurrentMonth: date.getMonth() === this.currentMonth,
          isToday: date.toDateString() === today.toDateString(),
          hasAppointments
        })
      }

      return days
    }
  },
  mounted() {
    this.loadAppointments()
  },
  methods: {
    async loadAppointments() {
      try {
        const response = await fetch('/admin/dashboard/appointments_data')
        this.appointments = await response.json()
      } catch (error) {
        console.error('Erro ao carregar compromissos:', error)
      }
    },
    previousMonth() {
      this.currentDate = new Date(this.currentYear, this.currentMonth - 1, 1)
      this.loadAppointments()
    },
    nextMonth() {
      this.currentDate = new Date(this.currentYear, this.currentMonth + 1, 1)
      this.loadAppointments()
    }
  }
}
</script>

<style scoped>
.calendar-grid {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}
</style>
