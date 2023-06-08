ActiveElement.JsonField = (() => {
  const cloneElement = (id) => ActiveElement.cloneElement('json', id);

  const humanize = ({ string, singular = false }) => {
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
      store.data[id] = data === undefined ? defaultValue : data;
      return id;
    };

    const buildState = ({ data, store, path = [] }) => {
      const getPath = (key) => {
        return path.concat([key]);
      };

      if (Array.isArray(data)) {
        return data.map((value, index) => buildState({ data: value, store, path: getPath(index) }));
      } else if (isObject(data)) {
        return Object.fromEntries(
          Object.entries(data).map(
            ([key, value]) => [key, buildState({ data: value, store, path: getPath(key) })]
          )
        );
      } else {
        return initializeState({ path, data });
      }
    };

    const state = buildState({ data, store });
    const stateChangedCallbacks = [];
    const stateChanged = (callback, state) => stateChangedCallbacks.push([callback, state]);
    const notifyStateChanged = () => {
      stateChangedCallbacks.forEach(([callback, state]) => callback({ getState, value: state && getValue(state) }));
    };
    const getValue = (id) => store.data[id];
    const deleteValue = (state) => {
      const deleteObject = (id) => {
        console.log(id);
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
      store.data[id] = null; // XXX: Do we need to do anything else here ?
      store.paths[id] = appendPath;
      return { state: id, path: appendPath };
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

    console.log(store.paths);
    return {
      stateChanged,
      connectState,
      store: { state, getValue, setValue, deleteValue, initializeState, appendValue },
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

  const Component = ({ store, stateChanged, connectState, schema, element }) => {
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
          const listItem = cloneElement('list-item');
          const objectField = ObjectField({
            path,
            omitLabel: true,
            schema: { ...schema.shape },
            state: eachState
          });

          // TODO: Use same template etc. for all delete buttons, use presentation layer to
          // handle UI differences.
          if (schema.shape.type == 'object') {
            const group = cloneElement('form-group');
            const deleteObjectButton = DeleteButton(
              { path, state: eachState, rootElement: listItem, template: 'delete-object-button' }
            );
            group.append(deleteObjectButton);
            group.append(objectField);

            if (schema.focus) {
              listItem.append(Focus({ state: eachState, schema, group, deleteObjectButton }));
            } else {
              listItem.append(group);
            }
          } else {
            listItem.append(objectField);
            listItem.append(DeleteButton({ path, state: eachState, rootElement: listItem }));
          }

          element.append(listItem);
        });
      }

      return element;
    };

    const Focus = ({ state, schema, group, deleteObjectButton }) => {
      const element = cloneElement('focus');
      const valueElement = document.createElement('a');
      const modal = cloneElement('modal');
      const modalBody = modal.querySelector('[data-field-type="modal-body"]');
      const titleElement = modal.querySelector('[data-field-type="modal-title"]');
      const pairs = schema.focus
                          .map((field) => [field, store.getValue(state[field])])
                          .filter(([_field, value]) => value)

      const [field, value] = (pairs.length && pairs[0]) || ['...', '...'];
      const bootstrapModal = new bootstrap.Modal(modal);

      stateChanged(({ value }) => {
        const isBoolean = typeof value === 'boolean';
        const fieldTitle = isBoolean ? humanize({ string: field }) : value;
        titleElement.innerText = fieldTitle;
        valueElement.innerText = fieldTitle;
        valueElement.classList.add('focus-field-value', isBoolean ? 'text-success' : 'text-primary');
      }, state[field]);

      connectState({ element: modal });

      valueElement.href = '#';
      modalBody.append(group);
      modalBody.classList.add('json-field');

      valueElement.addEventListener('click', (ev) => {
        ev.preventDefault();
        bootstrapModal.toggle();
      });
      element.append(valueElement);
      element.classList.add('focus', 'json-highlight');

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

      const humanName = humanize({ string: schema.name, singular: true });

      element.append(`Add ${humanName}`);
      element.classList.add('append-button', 'float-end');
      element.onclick = (ev) => {
        ev.preventDefault();
        const { path, state: appendState } = store.appendValue({ path: objectPath, schema });
        const listItem = cloneElement('list-item');
        const objectField = ObjectField({
          path,
          name: schema.name,
          omitLabel: true,
          state: appendState,
          schema: { ...schema.shape },
        });

        if (schema.shape.type == 'object') {
          listItem.append(DeleteButton({ path, state: appendState, rootElement: listItem, template: 'delete-object-button' }));
          listItem.append(objectField);
        } else {
          listItem.append(objectField);
          listItem.append(DeleteButton({ path, state: appendState, rootElement: listItem }));
        }
        list.append(listItem);

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
    const schema = getSchema(element);
    const { store, stateChanged, connectState } = createStore({ data, schema });

    connectState({ element });

    stateChanged(({ getState }) => {
      formFieldElement.value = JSON.stringify(getState());
      console.log(getState());
    });

    const component = Component({ store, stateChanged, connectState, schema, element });

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
