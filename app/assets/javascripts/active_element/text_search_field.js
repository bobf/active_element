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

  const getDisplayValue = ({ value, attributes, simplify = false }) => {
    if (attributes.length === 0) return value;
    if (attributes.length === 1 && attributes[0] === value) return value;
    if (simplify) return attributes[0];

    return attributes.join(', ');
  };

  const processResponse = ({
    element, response, hiddenInput, spinner, searchResultsContainer, responseErrorContainer
  }) => {
    spinner.classList.add('invisible');
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

          resultsItem.innerText = getDisplayValue({ value, attributes });
          resultsItem.addEventListener('click', () => {
            hiddenInput.value = value;
            element.value = getDisplayValue({ value, attributes, simplify: true });
            searchResultsContainer.replaceChildren();
            searchResultsContainer.classList.add('d-none');
          });
          searchResultsContainer.append(resultsItem);
        });

        searchResultsContainer.classList.remove('d-none');
      });
    } else {
      response.json().then((json) => responseErrorContainer.innerText = json.message)
                     .catch(() => responseErrorContainer.innerText = 'An unexpected error occurred');
    }
  };

  window.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('[data-field-type="text-search"]').forEach((element) => {
      const id = element.id;
      const hiddenId = `${id}-hidden-value`;
      const formId = element.dataset.formId;
      const form = document.querySelector(`#${formId}`);
      const hiddenInput = document.querySelector(`#${hiddenId}`);
      const model = element.dataset.searchModel;
      const attributes = tryParseJSON(element.dataset.searchAttributes, []);
      const value = element.dataset.searchValue;
      const token = ActiveElement.getAntiCsrfToken();
      const responseErrorContainer = cloneElement('response-error');
      const searchResultsContainer = cloneElement('results');
      const spinner = cloneElement('spinner');
      document.addEventListener('click', () => {
        searchResultsContainer.classList.add('d-none');
      });

      element.addEventListener('keyup', () => {
        const query = element.value;
        const requestId = ActiveElement.getRequestId();
        lastRequestId = requestId;

        spinner.classList.remove('invisible');
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
              ...{
                request_id: requestId,
                model,
                value,
                attributes,
                query,
              },
              ...(token.param && token.value ? { [token.param]: token.value } : {})
            }),
          }
        ).then((response) => processResponse(
          { element, response, spinner, hiddenInput, searchResultsContainer, responseErrorContainer }
        ));
      });

      form.append(hiddenInput);
      element.parentElement.append(searchResultsContainer);
      element.parentElement.append(spinner);
      element.parentElement.append(responseErrorContainer);
    });
  });
})();
