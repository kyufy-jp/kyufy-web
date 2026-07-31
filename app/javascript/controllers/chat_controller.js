import { Controller } from "@hotwired/stimulus"

// Chat form UX (SPEC §4): disable-on-submit + scroll-to-latest. The one Stimulus
// controller in the app. Attached to the screen wrapper; forms dispatch lock/unlock
// on turbo:submit-start / turbo:submit-end, and a MutationObserver on the stream
// target scrolls each appended assessment round into view.
export default class extends Controller {
  static targets = ["stream"]

  connect() {
    this.observer = new MutationObserver((mutations) => this.scrollToRound(mutations))
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

  // Scroll to the TOP of the round just appended, not the bottom of the stream. A round is
  // user bubble → summary → 逆質問 → verdict cards, so landing on its first node puts the
  // question on screen immediately; landing on lastElementChild would scroll past it to the
  // final card, which is the discoverability bug this ordering exists to fix.
  scrollToRound(mutations) {
    const firstAdded = mutations
      .flatMap((mutation) => Array.from(mutation.addedNodes))
      .find((node) => node.nodeType === Node.ELEMENT_NODE)

    const target = firstAdded ?? this.streamTarget.lastElementChild
    target?.scrollIntoView({ behavior: "smooth", block: "start" })
  }

  #submitButtons(form) {
    return form.querySelectorAll("input[type=submit], button[type=submit]")
  }
}
