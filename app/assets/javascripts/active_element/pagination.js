(() => {
  window.addEventListener(ActiveElement.reloadEvent, () => {
    const paginationSelect = document.querySelector('#collection-table-page-size-selector');

    if (paginationSelect) {
      paginationSelect.addEventListener('change', (ev) => {
        ev.stopPropagation();

        const params = new URLSearchParams(window.location.search);

        params.set('page_size', ev.target.value);
        window.location.search = params.toString();

        return false;
      });
    }
  });
})();
