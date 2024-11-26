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
            labels: {
              color: textColor,
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
      return {
        labels: data.labels,
        datasets: [
          {
            data: data.values,
            backgroundColor: this.generateColors(data.labels.length),
            borderWidth: 1,
          },
        ],
      }
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
    for (let i = 0; i < count; i++) {
      const hue = ((i * 360) / count) % 360
      colors.push(`hsl(${hue}, 70%, 50%)`)
    }
    return colors
  }
}
