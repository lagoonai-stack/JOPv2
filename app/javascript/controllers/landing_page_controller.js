import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "answer"]

    connect() {
        if (this.hasInputTarget) {
            this.typeText()
        }
    }

    typeText() {
        const inputElement = this.inputTarget;
        const text = inputElement.dataset.landingPageTypingTextValue || "Create a luxury real estate video.";
        let i = 0;

        // Clear initial content
        inputElement.textContent = "";

        const type = () => {
            if (i < text.length) {
                inputElement.textContent += text.charAt(i);
                i++;
                setTimeout(type, 50); // Adjust typing speed here
            }
        };

        // Start typing when element is in view (using Intersection Observer)
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    type();
                    observer.disconnect(); // Run once
                }
            });
        }, { threshold: 0.5 });

        observer.observe(inputElement);
    }

    toggleFaq(event) {
        const button = event.currentTarget;
        const answer = button.nextElementSibling;
        const icon = button.querySelector(".faq-icon");

        // Toggle hidden class on answer
        answer.classList.toggle("hidden");

        // Rotate icon (assuming simple plus/minus change or rotation)
        if (answer.classList.contains("hidden")) {
            icon.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5v14"/></svg>` // Plus
        } else {
            icon.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/></svg>` // Minus
        }
    }

    copyToClipboard(event) {
        const text = event.params.text;
        const copiedText = event.currentTarget.dataset.landingPageCopiedTextValue || "Copied!";

        navigator.clipboard.writeText(text).then(() => {
            const originalContent = event.currentTarget.innerHTML;
            event.currentTarget.innerHTML = `<span>${copiedText}</span>`;
            setTimeout(() => {
                event.currentTarget.innerHTML = originalContent;
            }, 2000);
        });
    }
}
