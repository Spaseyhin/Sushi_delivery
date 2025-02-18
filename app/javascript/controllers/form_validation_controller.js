import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["phone", "code"];

  connect() {
    console.log("FormValidationController подключен!");

    if (this.hasPhoneTarget) {
      this.phoneTarget.addEventListener("input", this.formatPhone.bind(this));
    }

    if (this.hasCodeTarget) {
      this.codeTarget.addEventListener("input", this.formatCode.bind(this));
    }
  }

  formatPhone(event) {
    let value = event.target.value;
    
    // Если номер не начинается с +7, добавляем
    if (!value.startsWith("+7")) {
      value = "+7" + value.replace(/[^0-9]/g, "");
    } else {
      value = "+7" + value.slice(2).replace(/[^0-9]/g, "");
    }

    // Ограничиваем длину номера (12 символов с +7)
    if (value.length > 12) {
      value = value.substring(0, 12);
    }

    event.target.value = value;
  }

  formatCode(event) {
    // Оставляем только цифры и ограничиваем длину 4 символами
    event.target.value = event.target.value.replace(/[^0-9]/g, "").substring(0, 4);
  }
}
