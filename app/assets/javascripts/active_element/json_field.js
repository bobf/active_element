ActiveElement.JsonField = (() => {
  const cloneElement = (id) => ActiveElement.cloneElement('json', id);

  const humanize = ({ string, singular = false }) => {
    if (!string) return '';

    const humanized = string.split('_').map(item => item.charAt(0).toUpperCase() + item.substring(1)).join(' ');

    if (!singular) return humanized;

    return humanized.replace(/s$/, ''); // FIXME: Expose translations from back-end to make this more useful.
  };

  const isObject = (object) => object && typeof object === 'object';

  const createStore = ({ data, schema, store = { data: {}, paths: {} } }) => {
    const initializeState = ({ state, path, data, defaultValue }) => {
      if (state) return state;

      const id = ActiveElement.generateId();
      store.paths[id] = path;
      store.data[id] = data === undefined ? (defaultValue || null) : data;
      return id;
    };

    const defaultState = ({ schema, path, defaultValue = null }) => {
      if (schema.type === 'object') {
        return Object.fromEntries(schema.shape.fields.map((field) => (
          [field.name, defaultState({
                         schema: field, path: path.concat([field.name]),
                         defaultValue: defaultValue && defaultValue[field.name],
                       })]
        )));
      } else if (schema.type === 'array') {
        return (defaultValue || []).map((item, index) => (
          defaultState({ schema: schema.shape, path: path.concat([index]), defaultValue: item })
        ));
      } else {
        const id = ActiveElement.generateId();
        store.data[id] = defaultValue; // TODO: Default value from schema
        store.paths[id] = path;
        return id;
      }
    };

    store.state = defaultState({ schema, path: [], defaultValue: data });
    console.log(store.state)

    const stateChangedCallbacks = [];
    const stateChanged = (callback, state) => stateChangedCallbacks.push([callback, state]);
    const notifyStateChanged = () => {
      stateChangedCallbacks.forEach(([callback, state]) => callback({ getState, value: state && getValue(state) }));
    };
    const getValue = (id) => store.data[id];
    const deleteValue = (state) => {
      const deleteObject = (id) => {
        if (Array.isArray(id)) {
          id.forEach((item) => deleteObject(item));
        } else if (isObject(id)) {
          Object.entries(id).forEach(([key, value]) => deleteObject(value));
        } else {
          store.data[id] = undefined;
          store.paths[id] = undefined;
        }
      };

      deleteObject(state);
      notifyStateChanged();
    };

    const setValue = (id, value) => {
      const previousValue = getValue(id);

      if (previousValue !== value) {
        store.data[id] = value;
        notifyStateChanged();
      }
    };

    const appendValue = ({ path, schema }) => {
      const getMaxIndex = (path) => {
        const matchingPaths = Object.values(store.paths).filter((storePath) => {
          const pathSlice = storePath?.slice(0, path.length);

          return pathSlice && path.every((item, index) => item === pathSlice[index]);
        });

        if (!matchingPaths.length) return undefined;

        return Math.max(...matchingPaths.map((matchingPath) => matchingPath[path.length]));
      };

      const id = ActiveElement.generateId();
      const maxIndex = getMaxIndex(path);
      const index = maxIndex === undefined ? 0 : maxIndex + 1;
      const appendPath = path.concat([index]);
      store.state[id] = defaultState({ schema: schema.shape, path: appendPath });
      // store.paths[id] = appendPath; // XXX Needed ?
      return { state: store.state[id], path: appendPath };
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

      const cleanEmpty = ((object) => {
        if (Array.isArray(object)) {
          const cleanedArray = Array.from(object.filter((item) => item !== undefined));
          return cleanedArray.map((item) => cleanEmpty(item));
        } else if (isObject(object)) {
          const cleanedObject = Object.fromEntries(
            Object.entries(object).filter(([key, value]) => value !== undefined)
          );
          return Object.fromEntries(
            Object.entries(cleanedObject).map(([key, value]) => [key, cleanEmpty(value)])
          );
        } else {
          return object;
        }
      });

      const data = { array: [], object: {} }[schema.type];

      Object.entries(store.paths).forEach(([id, path]) => {
        let value = data;

        path?.forEach((key, index) => {
          if (index === path.length - 1) {
            if (store.data[id] !== undefined) value[key] = store.data[id];
          } else {
            value[key] = value[key] || getStructure({ path: path.slice(0, index + 1) });
            value = value[key];
          }
        });
      });

      return cleanEmpty(data);
    };

    const handleEvent = (ev) => {
      const id = ev.target.id;
      setValue(id, getValueFromElement({ element: ev.target }));

      return true;
    };

    const connectState = ({ element }) => {
      element.addEventListener('keyup', (ev) => handleEvent(ev));
      element.addEventListener('change', (ev) => handleEvent(ev));
      notifyStateChanged();
    };

    return {
      stateChanged,
      connectState,
      store: { state: store.state, getValue, setValue, deleteValue, initializeState, appendValue },
    };
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

  const Component = ({ store, stateChanged, connectState, schema, element, fieldName }) => {
    const ObjectField = ({ schema, state, path, omitLabel = false }) => {
      const getPath = () => schema.name ? path.concat(schema.name) : path;
      const currentPath = getPath();

      let element;

      switch (schema.type) {
        case 'boolean':
          return BooleanField({ state, omitLabel, schema, path: currentPath });
        case 'string':
          return StringField({ state, omitLabel, schema, path: currentPath });
          break;
        case 'object':
          element = cloneElement('form-group-floating');
          (schema.shape.fields).forEach((field) => {
            element.append(
              ObjectField({
                name: field.name,
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
          element.append(AppendButton({ list, schema, state, path: currentPath }));
          element.append(Label({ title: schema.name }));
          element.append(list);
          return element;
      }
    };

    const BooleanField = ({ omitLabel, schema, state, path }) => {
      const checkbox = cloneElement('checkbox-field');

      checkbox.id = store.initializeState({ state, path, defaultValue: false });
      checkbox.checked = store.getValue(state);

      if (omitLabel) return checkbox;

      const element = cloneElement('form-check');

      element.append(checkbox);
      element.append(Label({ title: schema.name, template: 'form-check-label' }));

      return element;
    };

    const ArrayField = ({ schema, state, path: objectPath }) => {
      const element = cloneElement('list-group');

      if (state) {
        state.forEach((eachState, index) => {
          const path = objectPath.concat([index]);
          element.append(ArrayItem({ state: eachState, path, schema }));
        });
      }

      return element;
    };

    const ArrayItem = ({ state, path, schema, newItem = false }) => {
      const element = cloneElement('list-item');
      const objectField = ObjectField({
        path,
        omitLabel: true,
        schema: { ...schema.shape },
        state: state
      });

      // TODO: Use same template etc. for all delete buttons, use presentation layer to
      // handle UI differences.
      if (schema.shape.type == 'object') {
        const group = cloneElement('form-group');
        const deleteObjectButton = DeleteButton(
          { path, state, rootElement: element, template: 'delete-object-button' }
        );
        group.append(objectField);

        if (schema.focus) {
          element.append(Focus({ state, schema, group, deleteObjectButton, newItem }));
        } else {
          group.append(deleteObjectButton);
          element.append(group);
        }
      } else {
        element.append(objectField);
        element.append(DeleteButton({ path, state, rootElement: element }));
      }

      return element;
    };

    const Focus = ({ state, schema, group, deleteObjectButton, newItem }) => {
      const element = cloneElement('focus');
      const valueElement = document.createElement('a');
      const modal = cloneElement('modal');
      const modalBody = modal.querySelector('[data-field-type="modal-body"]');
      const modalHeader = modal.querySelector('.modal-header .modal-buttons');
      const titleElement = modal.querySelector('[data-field-type="modal-title"]');
      const bootstrapModal = new bootstrap.Modal(modal);

      stateChanged(() => {
        const pairs = schema.focus
                            .map((field) => [field, store.getValue(state[field])])
                            .filter(([_field, value]) => value)

        const [field, value] = (pairs.length && pairs[0]) || [null, '[New item]'];
        const isBoolean = typeof value === 'boolean';
        const fieldTitle = isBoolean ? humanize({ string: field }) : value;
        titleElement.innerText = fieldTitle;
        valueElement.innerText = fieldTitle;
        if (isBoolean) {
          valueElement.classList.add('text-success');
          valueElement.classList.remove('text-primary');
        } else {
          valueElement.classList.add('text-primary');
          valueElement.classList.remove('text-success');
        }
      });

      connectState({ element: modal });

      valueElement.classList.add('focus-field-value');
      valueElement.href = '#';
      modalBody.append(group);
      modalBody.classList.add('json-field');
      titleElement.append(deleteObjectButton);
      modalHeader.append(deleteObjectButton);
      deleteObjectButton.addEventListener('click', () => bootstrapModal.hide());

      valueElement.addEventListener('click', (ev) => {
        ev.preventDefault();
        bootstrapModal.toggle();
      });
      element.append(valueElement);
      element.classList.add('focus', 'json-highlight');

      if (newItem) bootstrapModal.toggle();

      return element;
    };

    const Label = ({ title, template }) => {
      const element = cloneElement(template || 'label');

      element.append(humanize({ string: title }));

      return element;
    }

    const Option = ({ value, label, selected }) => {
      const element = document.createElement('option');
      element.value = value;
      element.append(label || value);
      element.selected = selected || false;
      return element;
    };

    const Select = ({ state, schema }) => {
      const element = cloneElement('select')

      element.id = state;

      element.append(Option({ value: '' }));

      schema.options.forEach((value) => {
        element.append(Option({ value, selected: value === store.getValue(state) }));
      });

      return element;
    };

    const TextField = ({ template, state, schema, path }) => {
      const element = cloneElement(template || 'text-field');

      element.id = state;
      element.value = store.getValue(state);
      element.placeholder = schema.shape?.placeholder || ' ';

      return element;
    };

    const StringField = ({ omitLabel, schema, state, path }) => {
      let element;

      state = store.initializeState({ state, path, data: '' });

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

    const DeleteButton = ({ path, state, rootElement, template = 'delete-button' }) => {
      const element = cloneElement(template);

      element.onclick = (ev) => {
        ev.preventDefault();
        rootElement.remove(); // TODO: Handle confirmation callback.
        store.deleteValue(state);

        return false;
      };

      return element;
    };

    const AppendButton = ({ list, schema, state, path: objectPath }) => {
      const element = cloneElement('append-button');
      const humanName = humanize({ string: schema.name || fieldName, singular: true });

      element.append(`Add ${humanName}`);
      element.classList.add('append-button', 'float-end');
      element.onclick = (ev) => {
        ev.preventDefault();

        const { path, state: appendState } = store.appendValue({ path: objectPath, schema });

        list.append(ArrayItem({ path, state: appendState, schema, newItem: true }));

        return false;
      };

      return element;
    };

    element.append(ObjectField({ schema, omitLabel: true, state: store.state, path: [] }));
  };

  const JsonField = (element) => {
    const data = getData(element);
    const formId = element.dataset.formId;
    const formFieldElement = document.querySelector(`#${element.dataset.fieldId}`);
    const fieldName = element.dataset.fieldName;
    const schema = getSchema(element);
    const { store, stateChanged, connectState } = createStore({ data, schema });

    connectState({ element });

    stateChanged(({ getState }) => {
      formFieldElement.value = JSON.stringify(getState());
      console.log(getState());
    });

    const component = Component({ store, stateChanged, connectState, schema, element, fieldName });

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
