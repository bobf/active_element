(() => {
  window.addEventListener('DOMContentLoaded', () => {
    const timezoneOffset = new Date().getTimezoneOffset();
    document.cookie = `timezone_offset=${timezoneOffset};`;
  });
})();
