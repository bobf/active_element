(() => {
  const cloneElement = (id) => ActiveElement.cloneElement('theme', id);

  window.addEventListener(ActiveElement.reloadEvent, () => {
    const themeSelect = document.querySelector('#theme-select');

    const setTheme = (theme) => {
      const themeSelectButtons = themeSelect.children;

      Object.entries(themeSelectButtons).forEach(([_, element]) => {
        if (element.dataset.themeSwitchTo === theme) {
          element.classList.add('d-none');
        } else {
          element.classList.remove('d-none');
        }
      });

      localStorage.setItem('active_element-theme', theme);
      document.querySelector('html').dataset.bsTheme = theme;
    };


    const initTheme = () => {
      const theme = localStorage.getItem('active_element-theme') || 'light';
      const themeSelectButtons = document.querySelector('#theme-select-buttons').children;

      Object.entries(themeSelectButtons).forEach(([_, element]) => {
        themeSelect.append(element);

        element.addEventListener('click', (ev) => {
          ev.preventDefault();
          setTheme(element.dataset.themeSwitchTo);
          return false;
        });
      });

      setTheme(theme);
    };

    initTheme();
  });
})();
