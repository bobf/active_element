(() => {
  const cloneElement = (id) => ActiveElement.cloneElement('secret', id);

  window.addEventListener(ActiveElement.reloadEvent, () => {
    document.querySelectorAll('span[data-field-type="secret"]').forEach((element) => {
      const secret = element.dataset.secret;
      const showButton = cloneElement('show-button');
      const hideButton = cloneElement('hide-button');
      const content = cloneElement('content');
      const placeholder = secret.replace(/./g, '*');

      hideButton.classList.add('d-none');
      content.classList.add('font-monospace');
      content.classList.add('text-secondary');
      content.innerText = placeholder;

      showButton.addEventListener('click', () => {
        showButton.classList.add('d-none');
        hideButton.classList.remove('d-none');
        content.classList.remove('text-secondary');
        content.innerText = secret;

        return false;
      });

      hideButton.addEventListener('click', () => {
        showButton.classList.remove('d-none');
        hideButton.classList.add('d-none');
        content.classList.add('text-secondary');
        content.innerText = placeholder;

        return false;
      });

      element.append(content);
      element.append(showButton);
      element.append(hideButton);
    });
  });
})();
