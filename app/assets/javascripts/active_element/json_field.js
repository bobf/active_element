ActiveElement.JsonField = (() => {
  const cloneElement = (id) => ActiveElement.cloneElement('json', id);

  const humanize = ({ string, singular = false }) => {
    const humanized = string.split('_').map(item => item.charAt(0).toUpperCase() + item.substring(1)).join(' ');

    if (!singular) return humanized;

    return humanized.replace(/s$/, ''); // FIXME: Expose translations from back-end to make this more useful.
  };

  const createStore = ({ data, store = { data: {}, paths: {} } }) => {
    const buildState = ({ data, store, path = [] }) => {
      const getPath = (key) => {
        return path.concat([key]);
      };

      if (Array.isArray(data)) {
        return data.map((value, index) => buildState({ data: value, store, path: getPath(index) }));
      } else if (data && typeof(data) === 'object') {
        return Object.fromEntries(
          Object.entries(data).map(
            ([key, value]) => [key, buildState({ data: value, store, path: getPath(key) })]
          )
        );
      } else {
        const id = crypto.randomUUID();
        store.data[id] = data;
        store.paths[id] = path;
        return id;
      }
    };

    const state = buildState({ data, store });
    const getValue = (key) => store.data[key];
    const setValue = (key, value) => store.data[key] = value;

    return { state, store, getValue, setValue };
  };

  const getState = ({ store }) => {
    const data = {};
    const storeData = Object.entries(store.paths).forEach(([id, path]) => {
      let value = data;
      path.forEach((key, index) => {
        if (index === path.length - 1) {
          value[key] = store.data[id];
        } else if (typeof(key) === 'string') {
          value[key] = value[key] || {};
          value = value[key];
        } else {
          value[key] = value[key] || [];
          value = value[key];
        }
      });

      return value;
    },
    {});

    return data;
  };

  const getValueFromElement = ({ element }) => {
    if (element.type === 'checkbox') return element.checked;

    return element.value;
  };

  const getData = (element) => {
    const dataKey = element.dataset.dataKey;

    return ActiveElement.jsonData[dataKey].data;
  };

  const getSchema = (element) => {
    const dataKey = element.dataset.dataKey;

    return ActiveElement.jsonData[dataKey].schema;
  };

  const trackState = ({ element, schema, getValue }) => {
    element.addEventListener('change', (ev) => {
      const key = ev.target.id;
      const previousValue = getValue(key);
      const newValue = getValueFromElement({ element: ev.target });

      if (previousValue !== newValue) {
        // setValue(key, newValue);
        // TODO: Trigger callbacks
      }
      console.log(`Previous: ${previousValue}`);
      console.log(`Updated:  ${newValue}`);
      return true;
    });
  };

  const Component = ({ getValue, schema, state, element }) => {
    const ObjectField = ({ schema, state, floating = true, omitLabel = false }) => {
      let element;
      switch (schema.type) {
        case 'boolean':
          return BooleanField({ state, omitLabel, schema });
        case 'string':
          return StringField({ state, omitLabel, floating, schema });
          break;
        case 'object':
          element = cloneElement('form-group-floating');

          (schema.shape.fields).forEach((field) => {
            element.append(
              ObjectField({
                name: field.name,
                floating: false,
                schema: field,
                state: state ? state[field.name] : null,
              })
            );
          });

          return element;
        case 'array':
          element = cloneElement('form-group');
          const list = ArrayField({ schema, state });
          element.append(ExpandCollapseButton({ element }));
          element.append(Label({ title: schema.name }));
          element.append(list);
          element.append(AppendButton({ list, schema, state }));
          return element;
      }
    };

    const BooleanField = ({ omitLabel, schema, state }) => {
      const checkbox = cloneElement('checkbox-field');

      checkbox.id = state;
      checkbox.checked = getValue(state);

      if (omitLabel) return checkbox;

      const element = cloneElement('form-check');

      element.append(checkbox);
      element.append(Label({ title: schema.name, template: 'form-check-label' }));

      return element;
    };

    const ArrayField = ({ schema, state }) => {
      const element = cloneElement('list-group');

      if (state) {
        state.forEach((value) => {
          const listItem = cloneElement('list-item');
          const objectField = ObjectField({
            omitLabel: true,
            schema: { ...schema, ...schema.shape },
            state: value,
          });

          if (schema.shape.type == 'object') {
            const group = cloneElement('form-group');
            group.append(DeleteButton({ rootElement: listItem, template: 'delete-object-button' }));
            group.append(objectField);
            listItem.append(group);
          } else {
            listItem.append(objectField);
            listItem.append(DeleteButton({ rootElement: listItem }));
          }

          element.append(listItem);
        });
      }

      return element;
    };

    const Label = ({ title, template }) => {
      const element = cloneElement(template || 'label');

      element.append(humanize({ string: title }));

      return element;
    }

    const Select = ({ state, schema }) => {
      const element = cloneElement('select')

      element.id = state;

      schema.shape.options.forEach((option) => {
        const optionElement = document.createElement('option');
        optionElement.value = option;
        optionElement.append(option);
        optionElement.selected = option === getValue(state);
        element.append(optionElement);
      });

      return element;
    };

    const TextField = ({ template, state, schema }) => {
      const element = cloneElement(template || 'text-field');

      element.value = getValue(state) || '';
      element.id = state;
      element.placeholder = schema.shape?.placeholder || ' ';

      return element;
    };

    const StringField = ({ omitLabel, floating, schema, state }) => {
      let element;

      if (schema.shape?.options?.length) {
        element = Select({ state, schema });
      } else {
        element = TextField({ state, schema });
      }

      if (omitLabel) return element;

      const group = cloneElement('form-group-floating');

      group.append(element);
      group.append(Label({ title: schema.name }));

      return group;
    };

    const ExpandCollapseButton = ({ element }) => {
      const button = cloneElement('expand-collapse-button');

      button.onclick = (ev) => {
        ev.stopPropagation();
        element.classList.toggle('collapsed');

        if (element.classList.contains('collapsed')) {
          button.innerText = 'Show';
        } else {
          button.innerText = 'Hide';
        }

        return false;
      };

      return button;
    };

    const DeleteButton = ({ rootElement, template = 'delete-button' }) => {
      const element = cloneElement(template);

      element.onclick = (ev) => {
        ev.stopPropagation();
        rootElement.remove();

        return false;
      };

      return element;
    };

    const AppendButton = ({ list, schema, state }) => {
      const element = cloneElement('append-button');

      const humanName = humanize({ string: schema.name, singular: true });

      element.append(`Add ${humanName}`);
      element.onclick = (ev) => {
        ev.stopPropagation();
        const listItem = cloneElement('list-item');
        const objectField = ObjectField(
          { name: schema.name, omitLabel: true, state, schema: { ...schema, ...schema.shape } }
        );

        if (schema.shape.type == 'object') {
          listItem.append(DeleteButton({ rootElement: listItem, template: 'delete-object-button' }));
          listItem.append(objectField);
        } else {
          listItem.append(objectField);
          listItem.append(DeleteButton({ rootElement: listItem }));
        }
        list.append(listItem);

        return false;
      };

      return element;
    };

    element.append(ObjectField({ omitLabel: true, schema, state, getValue }));
  };

  const JsonField = (element) => {
    const data = getData(element);
    const schema = getSchema(element);
    const { state, store, getValue } = createStore({ data });

    console.log(getState({ store }));

    trackState({ element, schema, getValue });
    const component = Component({ getValue, schema, state, element });

    return component;
  };

  return JsonField;
})();

(() => {
  window.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.json-field').forEach((element) => {
      ActiveElement.JsonField(element);
    });
  });
})();
