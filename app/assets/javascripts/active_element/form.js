(() => {
  const cloneElement = (id) => ActiveElement.cloneElement('form', id);

  const initModalButtons = () => {
    document.querySelectorAll('[data-field-type="form-modal"]').forEach((element) => {
      const formId = element.dataset.formId;
      const form = document.querySelector(`#${formId}`);
      const wrapper = document.querySelector(`#form-wrapper-${formId}`);
      const modal = cloneElement('modal');
      const modalBody = modal.querySelector('[data-field-type="modal-body"]');
      const bootstrapModal = new bootstrap.Modal(modal);
      const title = element.dataset.formTitle;
      const titleElement = modal.querySelector('[data-field-type="modal-title"]');
      titleElement.append(title);

      modalBody.append(form);

      document.body.append(modal);

      element.addEventListener('click', () => {
        wrapper.classList.remove('d-none');
        bootstrapModal.toggle();
        return false;
      });
    });
  };

  const initClearFormButtons = () => {
    document.querySelectorAll('form').forEach((form) => {
      form.querySelectorAll('[data-form-input-type="clear"]').forEach((clearFormButton) => {
        clearFormButton.addEventListener('click', (ev) => {
          ev.preventDefault();

          form.querySelectorAll('.form-fields input:enabled, .form-fields select:enabled, .form-fields textarea:enabled')
              .filter((formInput) => !formInput.readonly)
              .forEach((formInput) => formInput.value = '');
        });
      });
    });
  };

  window.addEventListener('DOMContentLoaded', () => {
    initModalButtons();
    initClearFormButtons();
  });
})();
