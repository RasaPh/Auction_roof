import { Controller } from "@hotwired/stimulus"

// Swaps the large photo when a thumbnail is clicked.
export default class extends Controller {
  static targets = ["stage", "thumb"]

  show(event) {
    const button = event.currentTarget
    this.stageTarget.src = button.dataset.src
    this.thumbTargets.forEach((t) => t.classList.toggle("is-active", t === button))
  }
}
