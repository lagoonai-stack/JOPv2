import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["messages"];

  connect() {
    console.log("CHAT PAGE CONTROLLER CONNECTED");
    this.scrollMessagesToBottom();
    this.setupObserver();
  }

  disconnect() {
    this.observer?.disconnect();
  }

  // ── Dynamic getters (🔥 key fix) ──────────────────────────

  previewPanel() {
    return this.element.querySelector('[data-chat-page-target="previewPanel"]');
  }

  previewDropdown() {
    return this.element.querySelector(
      '[data-chat-page-target="previewDropdown"]',
    );
  }

  messagesEl() {
    return this.hasMessagesTarget
      ? this.messagesTarget
      : this.element.querySelector("#chat_messages");
  }

  // ── Scroll (more reliable) ────────────────────────────────

  setupObserver() {
    const el = this.messagesEl();
    if (!el) return;

    this.observer?.disconnect();

    this.observer = new MutationObserver(() => {
      this.scrollMessagesToBottom();
    });

    this.observer.observe(el, {
      childList: true,
    });
  }

  scrollMessagesToBottom() {
    const el = this.messagesEl();
    if (!el) return;

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        el.scrollTop = el.scrollHeight;
      });
    });
  }

  // ── Preview dropdown (no stale refs) ──────────────────────

  togglePreview(event) {
    event.stopPropagation();

    const panel = this.previewPanel();
    if (!panel) return;

    const isOpen = panel.classList.contains("preview-dropdown--open");
    isOpen ? this.closePreview() : this.openPreview();
  }

  openPreview() {
    const panel = this.previewPanel();
    const button = this.previewDropdown();

    panel?.classList.add("preview-dropdown--open");
    button?.setAttribute("aria-expanded", "true");
  }

  closePreview() {
    const panel = this.previewPanel();
    const button = this.previewDropdown();

    panel?.classList.remove("preview-dropdown--open");
    button?.setAttribute("aria-expanded", "false");
  }

  closePreviewOnOutsideClick(event) {
    const panel = this.previewPanel();
    const button = this.previewDropdown();

    if (
      panel?.classList.contains("preview-dropdown--open") &&
      !panel.contains(event.target) &&
      !button?.contains(event.target)
    ) {
      this.closePreview();
    }
  }

  // ── Conversations ─────────────────────────────────────────

  openConversations() {
    debugger;
    const dropdown = this.element.querySelector("#chat_conversations_dropdown");
    dropdown?.classList.add("chat-conversations--open");
    document.body.style.overflow = "hidden";
  }

  closeConversations() {
    const dropdown = this.element.querySelector("#chat_conversations_dropdown");
    dropdown?.classList.remove("chat-conversations--open");
    document.body.style.overflow = "";
  }
}
