(() => {
  window.addEventListener(ActiveElement.reloadEvent, () => {
    const timezoneOffset = new Date().getTimezoneOffset();
    document.cookie = `timezone_offset=${timezoneOffset};`;
  });
})();
