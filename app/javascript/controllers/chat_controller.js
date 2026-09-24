import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static targets = ["input", "submit"];
  static values = { active: Boolean };

  submitWithOptimistic(event) {
    if (!this.activeValue) return;

    const content = this.inputTarget.value.trim();
    if (!content) return;

    event.preventDefault();
    this.processSubmission(content);
  }

  handleKeydown(event) {
    if (event.key !== "Enter" || event.shiftKey) return;
    if (!this.activeValue) return;

    const content = this.inputTarget.value.trim();
    if (!content) return;

    event.preventDefault();
    this.processSubmission(content);
  }

  processSubmission(content) {
    const input = this.inputTarget;
    const submit = this.submitTarget;
    const formData = new FormData(this.element);

    // UI lock (fast feedback)
    input.value = "";
    input.disabled = true;
    submit.disabled = true;

    this.appendOptimisticMessage(content);
    requestAnimationFrame(() => this.appendThinking());

    const headers = {
      Accept: "text/vnd.turbo-stream.html",
      "X-Requested-With": "XMLHttpRequest",
    };

    const token = document
      .querySelector('meta[name="csrf-token"]')
      ?.getAttribute("content");

    if (token) headers["X-CSRF-Token"] = token;

    fetch(this.element.action, {
      method: "POST",
      body: formData,
      headers,
    })
      .then((response) => {
        if (!response.ok) throw new Error(response.statusText);
        return response.text();
      })
      .then((html) => {
        Turbo.renderStreamMessage(html);

        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            this.scrollToBottom();
          });
        });
      })
      .catch(() => {
        this.cleanupOptimistic();
        input.disabled = false;
        submit.disabled = false;
        alert("Something went wrong. Please try again.");
      });
  }

  // ── UI helpers ─────────────────────────────────────────────

  appendOptimisticMessage(content) {
    const messages = this.messagesContainer();
    if (!messages) return;

    const el = document.createElement("div");
    el.id = "chat_optimistic_user";
    el.className = "chat-message chat-message--user";
    el.dataset.role = "user";

    el.innerHTML = `
      <div class="chat-message__bubble">
        <div class="chat-message__content">
          ${escapeHtml(content).replace(/\n/g, "<br>")}
        </div>
      </div>
    `;

    messages.appendChild(el);
  }

  appendThinking() {
    const messages = this.messagesContainer();
    if (!messages) return;

    const el = document.createElement("div");
    el.id = "chat_thinking";
    el.className = "chat-message chat-message--assistant chat-thinking";
    el.dataset.role = "assistant";

    el.innerHTML = `
      <div class="chat-message__bubble chat-thinking__bubble">
        <div class="chat-thinking__dots">
          <span class="chat-thinking__dot"></span>
          <span class="chat-thinking__dot"></span>
          <span class="chat-thinking__dot"></span>
        </div>
        <span class="chat-thinking__label">Thinking…</span>
      </div>
    `;

    messages.appendChild(el);
    this.scrollToBottom();
  }

  cleanupOptimistic() {
    document.getElementById("chat_optimistic_user")?.remove();
    document.getElementById("chat_thinking")?.remove();
  }

  messagesContainer() {
    return document.getElementById("chat_messages");
  }

  scrollToBottom() {
    const el = this.messagesContainer();
    if (!el) return;

    requestAnimationFrame(() => {
      el.scrollTop = el.scrollHeight;
    });
  }
}

function escapeHtml(text) {
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}
