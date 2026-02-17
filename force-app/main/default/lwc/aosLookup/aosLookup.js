import AosBase, {showToast} from "c/aosBase";
import {NavigationMixin} from 'lightning/navigation';
import {api, track} from "lwc";

export default class AosLookup extends NavigationMixin(AosBase) {
    // Public
    @api placeholder = 'Search...';
    @api label;
    @api labelHidden = false;
    @api searchingMessage = 'Searching for';
    @api noResultsFoundMessage = 'No results found for';
    @api noRecordsMessage = 'No records';
    @api helpText;
    @api helpTextPlacement;
    @api iconTag;
    @api searchIconName = 'utility:search';
    @api value;
    @api disabled = false;
    @api readOnly = false;
    @api showNoneMessage = false;
    @api searchDebounce = 500;
    @api showRecentRecords = false;
    @api showAllRecords = false;
    @api isClickable = false;
    @api allowNewRecords = false;
    @api objectLabel;
    @api required = false;
    @api multiSelect;
    @api multiSelectValidation;
    // Query
    @api object;
    @api searchField = 'Name';
    @api subtitleField;
    @api additionalFields;
    @api showSubtitleLabel = false;
    @api subtitleSeparator;
    @api filter;
    @api order;
    @api limit = 10;
    @api valueField = 'Id';
    @api searchMode = 'SOSL';
    @api pillClass;
    // Private
    focused;
    isSearching;
    listBoxOptionClass = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';

    connectedCallback() {
        super.connectedCallback();
        this.doInit(); // To just set meta to default values
        this.meta.dto.searchTerm = '';
        if (this.showRecentRecords || this.value || this.showAllRecords) {
            this.search();
        }
    }

    @api
    validate() {
        this.clearErrors();
        let hasNoError = this.required === true && this.value || this.required !== true || this.required === undefined;
        if (!hasNoError) {
            this.showErrors(['Complete this field.']);
        }
        return hasNoError;
    }

    get elementContainerClasses() {
        return 'slds-form-element' + (this.hasErrors ? ' slds-has-error' : '');
    }

    handleFieldChangeOverridden(event) {
        super.handleFieldChange(event);
        this.isSearching = false;
        this.alignResults();

        // We search only when the user typed more than 1 symbol as SOSL does not support 1 symbol in the filter.
        // When less than 1 symbol AND show all records enabled the search mode switches to SOQL and able to find all the records.
        if ((this.meta.dto.searchTerm && this.meta.dto.searchTerm.length > (this.searchMode === 'SOQL' ? 0 : 1)) || this.showAllRecords === true) {
            this.isSearching = true;
            setTimeout(this.search.bind(this, this.meta.dto.searchTerm.slice()), this.searchDebounce);
        }
    }

    handleInputKeyDown(event) {
        if (this.disabled || this.readOnly) {
            return;
        }

        let KEYCODE_TAB = 9;

        let keyCode = event.which || event.keyCode || 0;

        if (keyCode === KEYCODE_TAB) {
            this.focused = false;
        }

    }

    handleInputKeyUp(event) {
        if (this.disabled || this.readOnly) {
            return;
        }

        let KEYCODE_ENTER = 13;
        let KEYCODE_UP = 38;
        let KEYCODE_DOWN = 40;

        let keyCode = event.which || event.keyCode || 0;

        if (keyCode === KEYCODE_ENTER) {
            let focusedIndex = this.searchResultsFiltered.findIndex(result => result.focused);
            focusedIndex = focusedIndex === -1 ? 0 : focusedIndex;
            this.setValue(this.searchResultsFiltered[focusedIndex].value);
            this.alignResults();
            this.focusOnSelectedRecord();
        } else if (keyCode === KEYCODE_UP) {
            let focusedIndex = this.searchResultsFiltered.findIndex(result => result.focused) - 1;
            focusedIndex = focusedIndex < 0 ? this.searchResultsFiltered.length - 1 : focusedIndex;
            this.focusOnResultLine(focusedIndex);
        } else if (keyCode === KEYCODE_DOWN) {
            let focusedIndex = this.searchResultsFiltered.findIndex(result => result.focused) + 1;
            focusedIndex = focusedIndex >= this.searchResultsFiltered.length ? 0 : focusedIndex;
            this.focusOnResultLine(focusedIndex);
        }
    }

    handleFocus(event) {
        this.focused = true;
        if (this.showAllRecords) {
            this.search();
        }
    }

    handleBlur(event) {
        this.focused = false;
    }

    handleClearClick(event) {
        let valueToRemove = event.currentTarget.dataset.value;
        if (valueToRemove) {
            this.setValue(valueToRemove, true);
        } else {
            this.setValue(undefined);
        }
        this.alignResults();
        this.focusOnSearchInput();
    }

    handleSelect(event) {
        this.setValue(event.currentTarget.dataset.value);
        this.alignResults();
    }

    handleRecordKeyUp(event) {
        if (this.disabled || this.readOnly) {
            return;
        }

        let KEYCODE_BACKSPACE = 8;
        let KEYCODE_ENTER = 13;

        let keyCode = event.which || event.keyCode || 0;

        if (keyCode === KEYCODE_BACKSPACE) {
            this.handleClearClick(event);
        } else if (keyCode === KEYCODE_ENTER) {
            this.handleRecordOpen(event);
        }
    }

    handleRecordOpen(event) {
        if (this.isClickable) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.currentTarget.dataset.value || this.value,
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url)
            });
        }
    }

    handleAddNewClick(event) {
        this.dispatchEvent(new CustomEvent('addnew', {
            bubbles: false,
            composed: false
        }));
    }

    handleSearchClick(event) {
        if (this.disabled || this.readOnly) return;
        this.dispatchEvent(new CustomEvent('searchiconclick', {
            bubbles: false,
            composed: false
        }));
    }

    get showList() {
        return this.focused && !this.selectedRecord && (this.showAllRecords == true || this.isSearching || this.filteredResultsFound || (this.noFilteredResultsFound && this.meta.dto.searchTerm));
    }

    get filteredResultsFound() {
        return this.searchResultsFiltered?.length > 0;
    }

    get searchResultsFound() {
        return this.meta?.dto?.searchResults?.length > 0;
    }

    get noFilteredResultsFound() {
        return this.searchResultsFiltered?.length === 0;
    }

    get noSearchResultsFound() {
        return this.meta?.dto?.searchResults?.length === 0;
    }

    get showNoResultsMessage() {
        return !this.isSearching && this.noFilteredResultsFound;
    }

    get noRecords() {
        return this.meta?.dto?.searchTerm ? this.noResultsFoundMessage + ' ' + this.meta.dto.searchTerm : this.noRecordsMessage
    }

    get showSearchForTerm() {
        return (this.meta?.dto?.searchTerm && (this.isSearching || this.noFilteredResultsFound)) || (!this.meta?.dto?.searchTerm && this.isSearching != true && this.showNoResultsMessage);
    }

    get searchingStatusMessage() {
        return this.meta.dto?.searchTerm ? this.searchingMessage + ' "' + this.meta.dto?.searchTerm + '"' :
            this.searchingMessage + ' records';
    }

    get pillClasses() {
        return 'slds-pill ' + (this.pillClass || '');
    }

    get selectedRecordContainerClasses() {
        return 'slds-combobox__form-element slds-input-has-icon ' + (this.disabled ? 'slds-input-has-icon_left' : 'slds-input-has-icon_left-right');
    }

    @api
    get selectedRecord() {
        return this.meta?.dto?.searchResults?.find(result => result.value === this.value);
    }

    @api
    get selectedRecords() {
        let result = this.meta?.dto?.searchResults?.filter(result => (this.value || []).indexOf(result.value) >= 0).map(item => {
            item.invalid = this.multiSelectValidation && this.multiSelectValidation[item.value] !== undefined;
            item.invalidMessage = this.multiSelectValidation ? this.multiSelectValidation[item.value] : undefined;
            item.pillClass = 'slds-pill ' + (item.invalid ? 'slds-has-error' : '') + (this.pillClass || '');
            return item;
        });
        return (result || []).length === 0 ? null : result;
    }

    get searchResultsFiltered() {
        return this.meta?.dto?.searchResults?.filter(result => this.value ? (this.multiSelect ? (this.value || []).indexOf(result.value) < 0 : result.value !== this.value) : true);
    }

    get iconName() {
        return (this.iconTag && (this.iconTag.startsWith('custom') || this.iconTag.startsWith('utility')) ? this.iconTag : 'standard:' + this.iconTag) || 'default';
    }

    focusOnResultLine(focusedIndex) {
        this.searchResultsFiltered.forEach(result => {
            result.focused = false;
            result.class = this.listBoxOptionClass;
        });
        this.searchResultsFiltered[focusedIndex].focused = true;
        this.searchResultsFiltered[focusedIndex].class = this.listBoxOptionClass + ' slds-has-focus';
        this.meta = this.meta;
    }

    focusOnSearchInput() {
        setTimeout(() => this.template.querySelector('[data-id="searchInput"]').focus());
    }

    focusOnSelectedRecord() {
        if (this.multiSelect) {
            setTimeout(() => this.template.querySelector('[data-value="' + this.selectedRecords?.pop()?.value + '"]').focus());
        } else {
            setTimeout(() => this.template.querySelector('[data-id="selectedRecord"]').focus());
        }
    }

    @api
    search(searchTerm) {
        if (!searchTerm || searchTerm === this.meta.dto.searchTerm) {
            this.isSearching = true;
            this.execute(
                'aos_LookupSearchProc',
                {
                    object: this.object,
                    searchField: this.searchField,
                    subtitleField: this.subtitleField,
                    additionalFields: this.additionalFields,
                    showSubtitleLabel: this.showSubtitleLabel,
                    subtitleSeparator: this.subtitleSeparator,
                    value: this.value,
                    valueField: this.valueField,
                    searchTerm: this.meta.dto.searchTerm,
                    filter: this.filter,
                    order: this.order,
                    limit: this.limit,
                    searchMode: this.searchMode,
                    multiSelect: this.multiSelect,
                    showRecentRecords: this.showRecentRecords,
                    showAllRecords: this.showAllRecords
                }
            ).then(meta => {
                this.meta.dto.recentResults = meta.dto.recentResults;
                this.meta.dto.searchResults = meta.dto.searchResults;
                this.iconTag = this.iconTag || meta.dto.iconTag;
                this.objectLabel = this.objectLabel || meta.dto.objectLabel || this.title;
                this.alignResults();
                this.meta = this.meta;
            }).catch(errors => {
                console.error(errors[0].message);
                // showToast(this, 'Error', errors[0].message, 'error');
            }).finally(() => {
                this.isSearching = false;
            });
        } else {
            this.isSearching = false;
        }
    }

    alignResults() {
        if (this.value && !this.meta.dto.searchTerm && this.searchResultsFound && !this.selectedRecord && (!this.selectedRecords || this.selectedRecords.length === 0)) {
            this.setValue(undefined);
        }
        let selectedRecordsClone = this.selectedRecords;
        // If search term is empty we reset results to hide "No records found" text
        if (this.showAllRecords == true && !this.meta.dto.searchTerm) {
            this.meta.dto.searchResults = this.meta.dto.searchResults;
        } else if (!this.meta.dto.searchTerm && (!this.value || this.multiSelect)) {
            // If there are recent records then we show them
            if (this.meta.dto.recentResults && this.meta.dto.recentResults.length > 0) {
                this.meta.dto.searchResults = selectedRecordsClone ? this.meta.dto.recentResults.concat(selectedRecordsClone.filter(selected => this.meta.dto.recentResults.findIndex(recent => recent.Id === selected.Id) < 0)) : this.meta.dto.recentResults;
            } else {
                this.meta.dto.searchResults = selectedRecordsClone?.length > 0 ? selectedRecordsClone : undefined;
            }
        } else {
            if (this.meta.dto.searchTerm.length <= 1) {
                // Reset search results when no records found to avoid showing blank list
                if (this.noSearchResultsFound) {
                    this.meta.dto.searchResults = selectedRecordsClone?.length > 0 ? selectedRecordsClone : undefined;
                }
            }
        }
        if (this.searchResultsFound) {
            this.meta.dto.searchResults.forEach(result => result.class = this.listBoxOptionClass);
        }
    }

    @api
    setValue(newValue, remove) {
        if (this.multiSelect && newValue) {
            this.value = [...(this.value || [])];
            if (remove === true) {
                this.value = this.value.filter(item => item !== newValue);
            } else {
                this.value.push(newValue);
            }
            this.meta.dto.searchTerm = undefined;
            this.value = Array.from(new Set(this.value));
            if (this.value.length === 0) {
                this.value = undefined;
            }
        } else {
            this.value = newValue;
            // this.meta.dto.searchTerm = '';
        }
        this.validate();
        this.triggerChangeEvent();
    }

    triggerChangeEvent() {
        this.dispatchEvent(new CustomEvent('change', {
            bubbles: false,
            composed: false,
            detail: {
                value: this.value
            }
        }));
    }
}