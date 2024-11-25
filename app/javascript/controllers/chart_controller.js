import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["allocation", "performance"]
  static values = {
    portfolioData: Object,
    performanceData: Object,
  }

  connect() {
    if (this.hasAllocationTarget) {
      this.initializeAllocationChart()
    }
    if (this.hasPerformanceTarget) {
      this.initializePerformanceChart()
    }
  }

  initializeAllocationChart() {
    const ctx = this.allocationTarget.getContext("2d")
    const { labels, data, colors } = this.portfolioDataValue

    new Chart(ctx, {
      type: "doughnut",
      data: {
        labels: labels,
        datasets: [
          {
            data: data,
            backgroundColor: colors,
            borderWidth: 1,
          },
        ],
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: "bottom",
            labels: {
              color: this.isDarkMode() ? "rgb(156, 163, 175)" : "rgb(55, 65, 81)",
            },
          },
          title: {
            display: true,
            text: "Portfolio Allocation",
            color: this.isDarkMode() ? "rgb(255, 255, 255)" : "rgb(17, 24, 39)",
            font: {
              size: 16,
            },
          },
        },
      },
    })
  }

  initializePerformanceChart() {
    const ctx = this.performanceTarget.getContext("2d")
    const { labels, values } = this.performanceDataValue

    new Chart(ctx, {
      type: "line",
      data: {
        labels: labels,
        datasets: [
          {
            label: "Value",
            data: values,
            borderColor: "rgb(59, 130, 246)",
            tension: 0.1,
            fill: {
              target: "origin",
              above: "rgba(59, 130, 246, 0.1)",
            },
          },
        ],
      },
      options: {
        responsive: true,
        scales: {
          x: {
            grid: {
              color: this.isDarkMode() ? "rgba(255, 255, 255, 0.1)" : "rgba(0, 0, 0, 0.1)",
            },
            ticks: {
              color: this.isDarkMode() ? "rgb(156, 163, 175)" : "rgb(55, 65, 81)",
              maxRotation: 45,
              minRotation: 45,
            },
          },
          y: {
            grid: {
              color: this.isDarkMode() ? "rgba(255, 255, 255, 0.1)" : "rgba(0, 0, 0, 0.1)",
            },
            ticks: {
              color: this.isDarkMode() ? "rgb(156, 163, 175)" : "rgb(55, 65, 81)",
              callback: (value) => {
                return new Intl.NumberFormat("en-US", {
                  style: "currency",
                  currency: "USD",
                }).format(value)
              },
            },
          },
        },
        plugins: {
          legend: {
            labels: {
              color: this.isDarkMode() ? "rgb(156, 163, 175)" : "rgb(55, 65, 81)",
            },
          },
          title: {
            display: true,
            text: "Performance History",
            color: this.isDarkMode() ? "rgb(255, 255, 255)" : "rgb(17, 24, 39)",
            font: {
              size: 16,
            },
          },
        },
      },
    })
  }

  isDarkMode() {
    return document.documentElement.classList.contains("dark")
  }
}
