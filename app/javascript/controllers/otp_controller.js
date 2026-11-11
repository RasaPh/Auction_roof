import { Controller } from "@hotwired/stimulus"

// 4-box OTP input: auto-advance, backspace to previous box, paste the whole code.
export default class extends Controller {
  static targets = ["digit"]

  next(event) {
    const input = event.target
    input.value = input.value.replace(/\D/g, "").slice(0, 1)
    const index = this.digitTargets.indexOf(input)
    if (input.value && index < this.digitTargets.length - 1) this.digitTargets[index + 1].focus()
  }

  back(event) {
    const index = this.digitTargets.indexOf(event.target)
    if (event.key === "Backspace" && !event.target.value && index > 0) this.digitTargets[index - 1].focus()
  }

  paste(event) {
    const digits = (event.clipboardData.getData("text") || "").replace(/\D/g, "").slice(0, this.digitTargets.length)
    if (!digits) return
    event.preventDefault()
    this.digitTargets.forEach((input, i) => { input.value = digits[i] || "" })
    this.digitTargets[Math.min(digits.length, this.digitTargets.length - 1)].focus()
  }
}
