(() => {
  const elements = [].slice.call(document.querySelectorAll('.toast'));
  const toasts = elements.map(function (element) {
    return new bootstrap.Toast(element, { animation: true, autohide: true, delay: 10000 })
  });

  toasts.forEach((toast) => toast.show());
})();
