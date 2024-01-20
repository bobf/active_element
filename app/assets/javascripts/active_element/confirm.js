(() => {
  const cloneElement = (id) => ActiveElement.cloneElement('form', id);

  window.addEventListener(ActiveElement.reloadEvent, () => {
    const confirmLinks = document.querySelectorAll('[data-confirm-action="true"]');

    confirmLinks.forEach((element) => {
      const modal = cloneElement('modal');
      const modalDialog = modal.querySelector('.modal-dialog');
      const modalBody = modal.querySelector('[data-field-type="modal-body"]');
      const modalFooter = modal.querySelector('[data-field-type="modal-footer"]');
      const bootstrapModal = new bootstrap.Modal(modal);
      const title = 'Confirm';
      const titleElement = modal.querySelector('[data-field-type="modal-title"]');
      const confirmButton = cloneElement('confirm-button');
      const confirmButtonLink = confirmButton.querySelector('a');
      const cancelButton = cloneElement('cancel-button');
      const cancelButtonLink = confirmButton.querySelector('a');

      element.dataset.actionConfirmed = 'false';
      titleElement.append(title);
      modalDialog.classList.remove('modal-xl');
      modalBody.append('Are you sure you want to perform this action?');
      modalFooter.append(cancelButton);
      modalFooter.append(confirmButton);


      if (element.dataset.method === 'delete') {
        confirmButtonLink.classList.remove('btn-primary');
        confirmButtonLink.classList.add('btn-danger');
      }

      cancelButton.addEventListener('click', (ev) => {
        ev.stopPropagation();
        ev.preventDefault();

        bootstrapModal.hide();

        return false;
      });

      confirmButtonLink.addEventListener('click', (ev) => {
        ev.stopPropagation();
        ev.preventDefault();

        element.dataset.actionConfirmed = 'true';
        element.click();

        return false;
      });

      element.addEventListener('click', (ev) => {
        if (element.dataset.actionConfirmed === 'true') {
          element.dataset.actionConfirmed = 'false';

          return true;
        }

        ev.stopPropagation();
        ev.preventDefault();
        bootstrapModal.show();

        return false;
      });
    });
  });
})();
