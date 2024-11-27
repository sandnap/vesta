import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["canvas"]
  static values = {
    chartType: String,
    data: Object,
  }

  connect() {
    this.initializeChart()
  }

  initializeChart() {
    const isDarkMode = document.documentElement.classList.contains("dark")
    const textColor = isDarkMode ? "#9ca3af" : "#374151"
    const gridColor = isDarkMode ? "#374151" : "#e5e7eb"

    const config = {
      type: this.chartTypeValue,
      data: this.chartData,
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: "right",
            labels: {
              color: textColor,
              padding: 20,
              font: {
                size: 12,
              },
            },
          },
          tooltip: {
            callbacks: {
              label: function (context) {
                const value = context.raw
                const total = context.dataset.data.reduce((a, b) => a + b, 0)
                const percentage = ((value / total) * 100).toFixed(1)
                return `${context.label}: ${new Intl.NumberFormat("en-US", {
                  style: "currency",
                  currency: "USD",
                }).format(value)}`
              },
            },
          },
        },
        scales:
          this.chartTypeValue === "line"
            ? {
                x: {
                  grid: {
                    color: gridColor,
                  },
                  ticks: {
                    color: textColor,
                  },
                },
                y: {
                  grid: {
                    color: gridColor,
                  },
                  ticks: {
                    color: textColor,
                    callback: function (value) {
                      return new Intl.NumberFormat("en-US", {
                        style: "currency",
                        currency: "USD",
                      }).format(value)
                    },
                  },
                },
              }
            : undefined,
      },
    }

    new Chart(this.canvasTarget, config)
  }

  get chartData() {
    const data = this.dataValue

    if (this.chartTypeValue === "doughnut") {
      const chartData = {
        labels: data.labels,
        datasets: [
          {
            data: data.values,
            backgroundColor: this.generateColors(data.labels.length),
            borderWidth: 1,
            borderColor: document.documentElement.classList.contains("dark") ? "#1f2937" : "#ffffff",
          },
        ],
      }
      return chartData
    }

    if (this.chartTypeValue === "line") {
      const isDarkMode = document.documentElement.classList.contains("dark")
      return {
        labels: data.labels,
        datasets: [
          {
            label: "Portfolio Value",
            data: data.values,
            borderColor: "#3b82f6",
            backgroundColor: isDarkMode ? "rgba(59, 130, 246, 0.2)" : "rgba(59, 130, 246, 0.1)",
            fill: true,
            tension: 0.4,
          },
        ],
      }
    }
  }

  generateColors(count) {
    const colors = []
    const baseHues = [210, 330, 120, 45, 275, 175, 15, 300] // Predefined hues for better color distribution

    for (let i = 0; i < count; i++) {
      const hue = baseHues[i % baseHues.length]
      const isDarkMode = document.documentElement.classList.contains("dark")

      if (isDarkMode) {
        colors.push(`hsla(${hue}, 70%, 60%, 0.8)`) // Brighter, slightly transparent colors for dark mode
      } else {
        colors.push(`hsl(${hue}, 70%, 50%)`) // Standard colors for light mode
      }
    }

    return colors
  }
}
