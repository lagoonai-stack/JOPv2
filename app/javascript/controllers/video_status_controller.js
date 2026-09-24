import { Controller } from "@hotwired/stimulus"

/**
 * VideoStatusController
 *
 * Polls the Rails `/conversations/:id/video/status` endpoint at a regular
 * interval while a video is rendering, updating the progress bar and label.
 * When the render completes (or errors), it stops polling and triggers a
 * Turbo Stream reload of the preview panel so the user sees the final state.
 *
 * Usage (in HAML):
 *   .video-preview__rendering{
 *     data: {
 *       controller: "video-status",
 *       video_status_conversation_id_value: conversation.id,
 *       video_status_url_value: conversation_video_status_path(...)
 *     }
 *   }
 */
export default class extends Controller {
  static targets = ["progressFill", "progressLabel", "statusLabel"]
  static values  = {
    url:            String,
    conversationId: String,
    pollInterval:   { type: Number, default: 3000 }, // ms between polls
  }

  connect() {
    this._timer     = null
    this._attempts  = 0
    this._maxErrors = 5 // stop after 5 consecutive network errors

    this._startPolling()
  }

  disconnect() {
    this._stopPolling()
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  _startPolling() {
    // Poll immediately, then on the interval
    this._poll()
    this._timer = setInterval(() => this._poll(), this.pollIntervalValue)
  }

  _stopPolling() {
    if (this._timer) {
      clearInterval(this._timer)
      this._timer = null
    }
  }

  async _poll() {
    try {
      const response = await fetch(this.urlValue, {
        method:  "GET",
        headers: {
          "Accept":           "application/json",
          "X-Requested-With": "XMLHttpRequest",
        },
        credentials: "same-origin",
      })

      if (!response.ok) {
        this._handleNetworkError(`HTTP ${response.status}`)
        return
      }

      const data = await response.json()
      this._attempts = 0 // reset error counter on success

      this._updateUI(data)

      if (data.status === "done" || data.status === "error") {
        this._stopPolling()
        // Small delay so the user sees the 100% state before the panel reloads
        setTimeout(() => this._reloadPreviewPanel(), 800)
      }
    } catch (err) {
      this._handleNetworkError(err.message)
    }
  }

  _updateUI(data) {
    const progress = Math.min(100, Math.max(0, data.progress ?? 0))

    // Progress bar fill
    if (this.hasProgressFillTarget) {
      this.progressFillTarget.style.width = `${progress}%`
    }

    // Progress label (e.g. "42%")
    if (this.hasProgressLabelTarget) {
      this.progressLabelTarget.textContent = `${progress}%`
    }

    // Status label text
    if (this.hasStatusLabelTarget) {
      if (data.status === "done") {
        this.statusLabelTarget.textContent = "Render complete!"
      } else if (data.status === "error") {
        this.statusLabelTarget.textContent =
          data.error ? `Error: ${data.error}` : "Something went wrong."
      } else if (data.warning) {
        // Transient connectivity issue — don't stop polling
        this.statusLabelTarget.textContent = "Connecting to render service…"
      } else {
        const pct = progress
        if (pct < 10) {
          this.statusLabelTarget.textContent = "Starting render…"
        } else if (pct < 50) {
          this.statusLabelTarget.textContent = "Rendering your video…"
        } else if (pct < 90) {
          this.statusLabelTarget.textContent = "Almost there…"
        } else {
          this.statusLabelTarget.textContent = "Finishing up…"
        }
      }
    }
  }

  _handleNetworkError(reason) {
    this._attempts++
    console.warn(`[VideoStatus] Poll error (${this._attempts}/${this._maxErrors}): ${reason}`)

    if (this._attempts >= this._maxErrors) {
      console.error("[VideoStatus] Too many consecutive errors — stopping poll.")
      this._stopPolling()
      if (this.hasStatusLabelTarget) {
        this.statusLabelTarget.textContent =
          "Lost connection to render service. Please refresh the page."
      }
    }
  }

  /**
   * Ask Turbo to reload the preview panel via a GET to the chat URL.
   * We fetch the current page as a Turbo Stream and let the server
   * decide what to render — or we can do a simpler full page reload.
   *
   * Here we do a targeted reload: navigate to the same URL, which causes
   * Turbo Drive to do a partial page update (morph).  This avoids a flash.
   */
  _reloadPreviewPanel() {
    if (typeof Turbo !== "undefined" && Turbo.visit) {
      // Turbo Drive visit with `action: "replace"` updates the page in-place
      Turbo.visit(window.location.href, { action: "replace" })
    } else {
      window.location.reload()
    }
  }
}
