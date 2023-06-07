ActiveElement.JsonField = (() => {
  const cloneElement = (id) => ActiveElement.cloneElement('json', id);

  const humanize = ({ string, singular = false }) => {
    const humanized = string.split('_').map(item => item.charAt(0).toUpperCase() + item.substring(1)).join(' ');

    if (!singular) return humanized;

    return humanized.replace(/s$/, ''); // FIXME: Expose translations from back-end to make this more useful.
  };

  const createStore = ({ data, schema, store = { data: {}, paths: {} } }) => {
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
        return initializeState({ path, data });
      }
    };

    const initializeState = ({ state, path, data, defaultValue }) => {
      if (state) return state;

      const id = ActiveElement.generateId();
      store.paths[id] = path;
      store.data[id] = data === undefined ? defaultValue : data;
      return id;
    };

    const state = buildState({ data, store });
    const getValue = (key) => store.data[key];
    const setValue = (key, value) => store.data[key] = value;
    const getMaxIndex = (path) => {
      const matchingPaths = Object.values(store.paths).filter((storePath) => {
        const pathSlice = storePath.slice(0, path.length);
        return path.every((item, index) => item === pathSlice[index]);
      });

      if (!matchingPaths.length) return undefined;

      return Math.max(...matchingPaths.map((matchingPath) => matchingPath[path.length]));
    };

    const appendValue = ({ path, schema }) => {
      const id = ActiveElement.generateId();
      const maxIndex = getMaxIndex(path);
      const index = maxIndex === undefined ? 0 : maxIndex + 1;
      store.data[id] = null; // XXX: Do we need to do anything else here ?
      store.paths[id] = path.concat([index]);
      return { state: id, index };
    };

    const getState = () => {
      const getStructure = ({ path }) => {
        return path.reduce((structure, key, index) => {
          let structureField;

          if (structure.type === 'object') {
            structureField = structure.shape.fields.find((field) => field.name === key);
          } else if (structure.type === 'array') {
            structureField = structure.shape;
          }

          if (index === path.length - 1) {
            return { array: [], object: {} }[structureField?.type || structure.shape.type];
          } else {
            return structureField;
          }
        }, schema);
      };

      const data = { array: [], object: {} }[schema.type];

      Object.entries(store.paths).forEach(([id, path]) => {
        let value = data;

        path.forEach((key, index) => {
          if (index === path.length - 1) {
            if (store.data[id] !== undefined) value[key] = store.data[id];
          } else {
            value[key] = value[key] || getStructure({ path: path.slice(0, index + 1) });
            value = value[key];
          }
        });
      });

      return data;
    };

    return { state, getValue, setValue, initializeState, appendValue, getState };
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

  const trackState = ({ element, schema, getValue, setValue, onStateChanged }) => {
    const handleUpdate = (ev) => {
      const id = ev.target.id;
      const previousValue = getValue(id);
      const newValue = getValueFromElement({ element: ev.target });

      if (previousValue !== newValue) {
        setValue(id, newValue);
        onStateChanged({ id, previousValue, newValue });
      }
      return true;
    };

    element.addEventListener('keyup', (ev) => handleUpdate(ev));
    element.addEventListener('change', (ev) => handleUpdate(ev));
  };

  const Component = ({ getValue, appendValue, initializeState, schema, state, element }) => {
    const ObjectField = ({ schema, state, path, floating = true, omitLabel = false }) => {
      const getPath = () => schema.name ? path.concat(schema.name) : path;
      const currentPath = getPath();

      let element;

      switch (schema.type) {
        case 'boolean':
          return BooleanField({ state, omitLabel, schema, path: currentPath });
        case 'string':
          return StringField({ state, omitLabel, floating, schema, path: currentPath });
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
                path: currentPath,
              })
            );
          });

          return element;
        case 'array':
          element = cloneElement('form-group');
          const list = ArrayField({ schema, state, path: currentPath });
          element.append(Label({ title: schema.name }));
          element.append(list);
          element.append(AppendButton({ list, schema, state, path: currentPath }));
          return element;
      }
    };

    const BooleanField = ({ omitLabel, schema, state, path }) => {
      const checkbox = cloneElement('checkbox-field');

      checkbox.id = initializeState({ state, path, defaultValue: false });
      checkbox.checked = getValue(state);

      if (omitLabel) return checkbox;

      const element = cloneElement('form-check');

      element.append(checkbox);
      element.append(Label({ title: schema.name, template: 'form-check-label' }));

      return element;
    };

    const ArrayField = ({ schema, state, path }) => {
      const element = cloneElement('list-group');

      if (state) {
        state.forEach((value, index) => {
          const listItem = cloneElement('list-item');
          const objectField = ObjectField({
            omitLabel: true,
            schema: { ...schema.shape },
            state: value,
            path: path.concat([index]),
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

      schema.options.forEach((option) => {
        const optionElement = document.createElement('option');
        optionElement.value = option;
        optionElement.append(option);
        optionElement.selected = option === getValue(state);
        element.append(optionElement);
      });

      return element;
    };

    const TextField = ({ template, state, schema, path }) => {
      const element = cloneElement(template || 'text-field');

      element.id = state;
      element.value = getValue(state);
      element.placeholder = schema.shape?.placeholder || ' ';

      return element;
    };

    const StringField = ({ omitLabel, floating, schema, state, path }) => {
      let element;

      state = initializeState({ state, path, data: '' });

      if (schema.options?.length) {
        element = Select({ state, schema, path });
      } else {
        element = TextField({ state, schema, path });
      }

      if (omitLabel) return element;

      const group = cloneElement('form-group-floating');

      group.append(element);
      group.append(Label({ title: schema.name }));

      return group;
    };

    const DeleteButton = ({ rootElement, template = 'delete-button' }) => {
      const element = cloneElement(template);

      element.onclick = (ev) => {
        ev.preventDefault();
        rootElement.remove(); // TODO: Handle confirmation callback.

        return false;
      };

      return element;
    };

    const AppendButton = ({ list, schema, state, path }) => {
      const element = cloneElement('append-button');

      const humanName = humanize({ string: schema.name, singular: true });

      element.append(`Add ${humanName}`);
      element.onclick = (ev) => {
        ev.preventDefault();
        const { index, state: appendState } = appendValue({ path, schema });
        const listItem = cloneElement('list-item');
        const objectField = ObjectField({
          name: schema.name,
          omitLabel: true,
          state: appendState,
          schema: { ...schema.shape },
          path: path.concat([index]),
        });

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

    element.append(ObjectField({ omitLabel: true, schema, state, getValue, path: [] }));
  };

  const JsonField = (element) => {
    const data = getData(element);
    const formId = element.dataset.formId;
    const formFieldElement = document.querySelector(`#${element.dataset.fieldId}`);
    const schema = getSchema(element);
    const { state, getValue, setValue, appendValue, initializeState, getState } = createStore({ data, schema });

    const onStateChanged = ({ id, previousValue, newValue }) => {
      formFieldElement.value = JSON.stringify(getState());
      ActiveElement.log(`Previous: ${previousValue}`);
      ActiveElement.log(`Updated:  ${newValue}`);
    };
    trackState({ element, schema, getValue, setValue, onStateChanged });
    const component = Component({ getValue, appendValue, initializeState, schema, state, element });

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
