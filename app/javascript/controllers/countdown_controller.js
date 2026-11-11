import { Controller } from "@hotwired/stimulus"

// Counts down to `at`. With refresh=true, reloads the page when time is up
// so the bid form and status follow the server.
export default class extends Controller {
  static values = { at: String, refresh: Boolean }

  connect() {
    this.target = new Date(this.atValue).getTime()
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const left = Math.max(0, Math.floor((this.target - Date.now()) / 1000))
    const d = Math.floor(left / 86400)
    const pad = (n) => String(n).padStart(2, "0")
    const hms = `${pad(Math.floor(left / 3600) % 24)}:${pad(Math.floor(left / 60) % 60)}:${pad(left % 60)}`
    this.element.textContent = d > 0 ? `${d} วัน ${hms}` : hms
    this.element.classList.toggle("is-urgent", left > 0 && left <= 600)

    if (left === 0) {
      clearInterval(this.timer)
      if (this.refreshValue) setTimeout(() => Turbo.visit(window.location.href, { action: "replace" }), 2500)
    }
  }
}
