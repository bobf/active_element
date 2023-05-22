(() => {
  const cloneElement = (id) => ActiveElement.cloneElement('form', id);

  const initExpandButtons = () => {
    document.querySelectorAll('[data-field-type="form-expand"]').forEach((element) => {
      const formId = element.dataset.formId;
      const form = document.querySelector(`#${formId}`);
      const wrapper = document.querySelector(`#form-wrapper-${formId}`);
      const expandButton = cloneElement('expand-button');
      const collapseButton = cloneElement('collapse-button');

      collapseButton.classList.add('d-none');
      wrapper.classList.add('collapsed');

      const toggle = ({ show, ev }) => {
        ev.stopPropagation();
        form.classList.remove('d-none');
        collapseButton.classList.toggle('d-none');
        expandButton.classList.toggle('d-none');
        wrapper.classList.toggle('collapsed');

        return false;
      };

      expandButton.addEventListener('click', (ev) => toggle({ show: true, ev }));
      collapseButton.addEventListener('click', (ev) => toggle({ show: false, ev }));

      element.append(expandButton);
      element.append(collapseButton);
    });
  };

  const initPopupButtons = () => {
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

  window.addEventListener('DOMContentLoaded', () => {
    initExpandButtons();
    initPopupButtons();
  });
})();
