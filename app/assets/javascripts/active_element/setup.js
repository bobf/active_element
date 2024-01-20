(() => {
  const generateId = () => {
    return `ae-${crypto.randomUUID()}`;
  };

  const getAntiCsrfToken = () => {
    const param = document.querySelector('meta[name="csrf-param"]')?.content;
    const value = document.querySelector('meta[name="csrf-token"]')?.content;

    return { param, value };
  };

  const cloneElement = (category, id) => {
    const element = document.querySelector(`#${category}-templates`)
                            .querySelector(`#${category}-${id}-template`)
                            .cloneNode(true);
    element.id = ActiveElement.generateId();
    return element;
  };

  const navbar = document.querySelector('.navbar.application-menu');

  window.addEventListener('scroll', () => {
    if (!navbar) return;

    if (window.scrollY > 50) {
      navbar.classList.add('shrink');
    } else {
      navbar.classList.remove('shrink');
    }
  });


  const ActiveElement = {
    debug: false,
    reloadEvent: window.ActiveElement.turbo ? 'turbo:load' : 'DOMContentLoaded',
    log: {
      debug: (message) => { ActiveElement.debug && console.log(`[ActiveElement:debug]`, message); },
      info: (message) => { console.log(`[ActiveElement:info] ${message}`); },
      error: (message) => { console.log(`[ActiveElement:error] ${message}`); },
    },
    generateId,
    getAntiCsrfToken,
    cloneElement,
    components: {},
    getRequestId: () => ActiveElement.generateId(),
    jsonData: window.ActiveElement?.jsonData || {},
    controller_path: document.querySelector('meta[name="active_element_controller_path"]').content
  };

  window.ActiveElement = { ...(window.ActiveElement || {}), ...ActiveElement };
})();

ActiveElement.log.info('Initialized');
