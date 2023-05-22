(() => {
  const generateId = () => {
    ActiveElement._id += 1;

    return `active-element-element-${ActiveElement._id}`;
  };

  const getAntiCsrfToken = () => {
    const param = document.querySelector('meta[name="csrf-param"]').content;
    const value = document.querySelector('meta[name="csrf-token"]').content;

    return { param, value };
  };

  const cloneElement = (category, id) => {
    const element = document.querySelector(`#${category}-templates`)
                            .querySelector(`#${category}-${id}-template`)
                            .cloneNode(true);
    element.id = ActiveElement.generateId();
    return element;
  };

  const ActiveElement = {
    log: (message) => { console.log(`[ActiveElement] ${message}`); },
    _id: 0,
    generateId,
    getAntiCsrfToken,
    cloneElement,
    components: {},
    jsonData: {},
  };

  window.ActiveElement = ActiveElement;
})();

ActiveElement.log('Initialized');
