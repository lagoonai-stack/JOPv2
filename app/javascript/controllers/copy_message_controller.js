import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String }

  copy(event) {
    event.preventDefault()
    const content = this.contentValue
    if (!content) return
    navigator.clipboard.writeText(content).then(() => {
      const btn = this.element.querySelector(".chat-message__copy")
      if (btn) {
        const orig = btn.title
        btn.title = "Copied!"
        btn.classList.add("chat-message__copy--copied")
        setTimeout(() => {
          btn.title = orig
          btn.classList.remove("chat-message__copy--copied")
        }, 1500)
      }
    })
  }
}
