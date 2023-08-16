/*
 * MIT License Copyright (c) 2017 Israel Muñoz
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 * and associated documentation files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions: The above copyright
 * notice and this permission notice shall be included in all copies or substantial portions of
 * the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 *! multiselect-dropdown v2.0
 *  Multi-select drop-down control to replace regular select element.
 *  https://github.com/israel-munoz/multiselect-dropdown
 */

/**
 * @typedef MultiSelectOptions
 * @property { string } className Custom classes to add to the element.
 * @property { number } maxVisibleOptions Max number of options visible in the dropdown panel.
 */

class multiSelect {
  /**
   * @param { HTMLSelectElement } select HTML select element to convert into multiselect dropdown.
   * @param { MultiSelectOptions } options Optional settings for the multiselect object.
   */
  constructor(select, options) {
    this.options = Object.assign({}, this.defaultOptions, options);
    this.element = document.createElement('div');
    const display = document.createElement('div');
    const optionsList = document.createElement('div');

    select.classList.add('multi-select-element');
    select.multiple = true;

    this.element.classList.add('multi-select');
    select.parentElement.insertBefore(this.element, select);
    this.element.appendChild(select);
    this.element.appendChild(display);
    this.element.appendChild(optionsList);
    const closeOptions = () => {
      if (this.overlay) {
        this.element.classList.remove('multi-select-open');
        this.element.appendChild(optionsList);
        this.overlay.remove();
        delete this.overlay;
        this._updateDisplay();
        window.removeEventListener('scroll', onscroll);
      }
    };
    const onscroll = () => this._moveOptions();
    const onwindowclick = evt => {
      if (!this._isOptionsPanel(evt.target)) {
        closeOptions();
        window.removeEventListener('click', onwindowclick);
      }
    };

    display.classList.add('multi-select-display');
    display.addEventListener('click', () => {
      let overlay = this.overlay;
      if (overlay) {
        closeOptions();
      } else {
        const rect = this.element.getBoundingClientRect();
        this.element.classList.add('multi-select-open');
        overlay = document.createElement('div');
        overlay.classList.add('multi-select-options-overlay', `overlay-${Number(new Date())}`);
        overlay.appendChild(optionsList);
        document.body.appendChild(overlay);
        this.overlay = overlay;
        optionsList.style.width = `${rect.width}px`;
        this._setOptionsSize();
        this._moveOptions();
        window.addEventListener('scroll', onscroll);
        setTimeout(() => { window.addEventListener('click', onwindowclick); }, 1);
      }
    });
    this._updateDisplay();

    optionsList.classList.add('multi-select-options');
    this.reload();
    this.element.multiSelect = this;
  }

  /**
   * Reset multi-select control options.
   * @param { MultiSelectOptions } options
   */
  setConfig(options) {
    this.options = Object.assign({}, this.defaultOptions, options);
    this.element.className = 'multi-select';
    if (this.options.className) {
      this.element.classList.add(this.options.className.split(' '));
    }
    if (this.overlay) {
      this._setOptionsSize();
    }
  }

  reload() {
    const optionsList = this.element.querySelector('.multi-select-options');
    const select = this.element.querySelector('.multi-select-element');
    optionsList.innerHTML = '';
    select.querySelectorAll('option').forEach(op => {
      const item = document.createElement('div');
      const input = document.createElement('input');
      const label = document.createElement('label');

      item.classList.add('option');
      item.appendChild(label);

      input.type = 'checkbox';
      input.value = op.value;
      input.checked = op.selected;
      input._multiSelectOption = op;
      input.addEventListener('change', () => { op.selected = input.checked; }, false);

      label.appendChild(input);
      label.appendChild(document.createTextNode(op.textContent));

      optionsList.appendChild(item);
    });
  }

  /** @type { MultiSelectOptions } Default options for multiselect-dropdown */
  defaultOptions() {
    return {
      className: '',
      maxVisibleOptions: 10
    };
  };

  _updateDisplay() {
    const display = this.element.querySelector('.multi-select-display');
    const options = this.element.querySelectorAll('.multi-select-element option');
    const texts = [];
    options.forEach(op => {
      if (op.selected) {
        texts.push(op.textContent);
      }
    });
    display.textContent = texts.join(', ');
  }

  _setOptionsSize() {
    /** @type { HTMLElement } */
    const optionsList = this.overlay.querySelector('.multi-select-options');
    if (optionsList.children.length) {
      const maxVisibleOptions = Math.min(this.options.maxVisibleOptions || optionsList.children.length, optionsList.children.length);
      const childrenHeight = optionsList.children[0].getBoundingClientRect().height;
      optionsList.style.maxHeight = `${Math.min(childrenHeight * maxVisibleOptions, window.innerHeight)}px`;
    }
  }

  /**
   * @param { HTMLElement } element
   */
  _isOptionsPanel(element) {
    let p = element;
    do {
      if (p === this.overlay) {
        return true;
      }
    } while ((p = p.parentElement));
    return false;
  }

  _moveOptions() {
    const selectRect = this.element.getBoundingClientRect();
    /** @type { HTMLElement } */
    const optionsList = this.overlay.querySelector('.multi-select-options');
    const optsRect = optionsList.getBoundingClientRect();
    let y = selectRect.top + selectRect.height;
    const x = selectRect.left + window.scrollX;
    y = (y + optsRect.height < window.innerHeight ? y : window.innerHeight - optsRect.height) + window.scrollY;
    optionsList.style.top = `${y}px`;
    optionsList.style.left = `${x}px`;
  }
}
