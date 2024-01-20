(() => {
  window.addEventListener(ActiveElement.reloadEvent, () => {
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
    const popoverList = popoverTriggerList.map(function (element) {
      return new bootstrap.Popover(element)
    })
  });
})();
