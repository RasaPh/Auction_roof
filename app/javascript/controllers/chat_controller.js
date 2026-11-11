import { Controller } from "@hotwired/stimulus"

// Keeps the chat scrolled to the newest message as messages stream in.
export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.scroll()
    this.observer = new MutationObserver(() => this.scroll())
    this.observer.observe(this.listTarget, { childList: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  scroll() {
    this.listTarget.scrollTop = this.listTarget.scrollHeight
  }
}
