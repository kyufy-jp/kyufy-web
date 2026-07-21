import { Controller } from "@hotwired/stimulus"

// Chat form UX (SPEC §4): disable-on-submit + scroll-to-latest. The one Stimulus
// controller in the app. Attached to the screen wrapper; forms dispatch lock/unlock
// on turbo:submit-start / turbo:submit-end, and a MutationObserver on the stream
// target scrolls each appended assessment round into view.
export default class extends Controller {
  static targets = ["stream"]

  connect() {
    this.observer = new MutationObserver(() => this.scrollToLatest())
    if (this.hasStreamTarget) {
      this.observer.observe(this.streamTarget, { childList: true })
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }

  lock(event) {
    this.#submitButtons(event.target).forEach((button) => (button.disabled = true))
  }

  unlock(event) {
    this.#submitButtons(event.target).forEach((button) => (button.disabled = false))
  }

  scrollToLatest() {
    this.streamTarget.lastElementChild?.scrollIntoView({ behavior: "smooth", block: "start" })
  }

  #submitButtons(form) {
    return form.querySelectorAll("input[type=submit], button[type=submit]")
  }
}
