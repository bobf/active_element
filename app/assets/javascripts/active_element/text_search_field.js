(() => {
  let lastRequestId;

  const cloneElement = (id) => ActiveElement.cloneElement('form-search-field', id);

  const tryParseJSON = (json, defaultValue) => {
    try {
      return JSON.parse(json);
    } catch (error) {
      ActiveElement.log.error(error);
      return defaultValue;
    }
  };

  const processResponse = ({
    element, response, hiddenInput, spinner, clearButton, searchResultsContainer, responseErrorContainer
  }) => {
    spinner.classList.add('invisible');
    clearButton.classList.remove('invisible');

    if (response.ok) {
      response.json().then((json) => {
        if (json.request_id !== lastRequestId) {
          return;
        }

        responseErrorContainer.innerText = '';

        if (!json.results.length) {
          responseErrorContainer.innerText = `No matching results for ${element.value}`;
          return;
        }

        json.results.forEach(({ value, attributes }) => {
          const resultsItem = cloneElement('results-item');

          resultsItem.innerText = attributes.length === 0 ? value : `${attributes.join(', ')} (${value})`;
          resultsItem.addEventListener('click', () => {
            hiddenInput.value = value;
            element.value = value;
            searchResultsContainer.replaceChildren();
            searchResultsContainer.classList.add('d-none');
          });
          searchResultsContainer.append(resultsItem);
        });

        searchResultsContainer.classList.remove('d-none');
      });
    } else {
      response.json().then((json) => responseErrorContainer.innerText = json.message)
                     .catch(() => responseErrorContainer.innerText = 'An unepxected error occurred');
    }
  };

  window.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('[data-field-type="text-search"]').forEach((element) => {
      const id = element.id;
      const hiddenId = `${id}-hidden-value`;
      const formId = element.dataset.formId;
      const form = document.querySelector(`#${formId}`);
      const model = element.dataset.searchModel;
      const attributes = tryParseJSON(element.dataset.searchAttributes, []);
      const value = element.dataset.searchValue;
      const token = ActiveElement.getAntiCsrfToken();
      const hiddenInput = cloneElement('hidden-input');
      const responseErrorContainer = cloneElement('response-error');
      const searchResultsContainer = cloneElement('results');
      const spinner = cloneElement('spinner');
      const clearButton = cloneElement('clear-button');
      document.addEventListener('click', () => {
        searchResultsContainer.classList.add('d-none');
      });

      clearButton.addEventListener('click', () => {
        element.value = '';
        hiddenInput.value = '';
        responseErrorContainer.innerText = '';
        spinner.classList.add('invisible');
        clearButton.classList.add('invisible');
      });

      element.addEventListener('keyup', () => {
        const query = element.value;
        const requestId = crypto.randomUUID();
        lastRequestId = requestId;

        clearButton.classList.add('invisible');
        spinner.classList.remove('invisible');
        hiddenInput.value = query;
        searchResultsContainer.classList.add('d-none');

        if (!query || query.length < 3) {
          spinner.classList.add('invisible');
          return;
        }

        searchResultsContainer.replaceChildren();

        fetch(
          `/${ActiveElement.controller_path}/_active_element_text_search/`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              request_id: requestId,
              model,
              value,
              attributes,
              query,
              [token.param]: token.value,
            }),
          }
        ).then((response) => processResponse(
          { element, response, spinner, clearButton, hiddenInput, searchResultsContainer, responseErrorContainer }
        ));
      });

      hiddenInput.name = element.name;
      if (element.value) hiddenInput.value = element.value;
      form.append(hiddenInput);
      element.parentElement.append(searchResultsContainer);
      element.parentElement.append(clearButton);
      element.parentElement.append(spinner);
      element.parentElement.append(responseErrorContainer);
    });
  });
})();
