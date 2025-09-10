({
    init: function(component) {

        const contextComponent = component.get('v.context');
        const utilsProps = {
            _component: {
                writable: false,
                configurable: false,
                enumerable: false,
                value: contextComponent,
            },
        };

        const utils = Object.create(this.getUtils(), utilsProps);

        const componentProps = {
            writable: false,
            configurable: false,
            enumerable: false,
            value: utils,
        };
        Object.defineProperty(contextComponent, 'utils', componentProps);
    },

    getUtils: function() {
        if (!this._utils) {
            this._utils = this.createUtils();
        }

        return this._utils;
    },

    createUtils: function() {

        return {
            callApex : this.callApex,
            callBackgroundApex : this.callBackgroundApex,
            callApexPromise : this.callApexPromise,
            check: function () {
                console.log('CHECK!!!')
            },
            showToast: this.showToast,
            b64toBlob: this.b64toBlob
        }

    },

    callApexPromise: function (action, params) {
        return new Promise(function (resolve, reject) {
            action.setParams(params);
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(':::::state::::' + state);
                if (state === "SUCCESS") {
                    var retVal = response.getReturnValue();
                    resolve(retVal);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors.length && errors[0] && errors[0].message) {
                        reject(new Error(errors[0].message));
                    } else {
                        reject(new Error("Unknown error"));
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },

    callApex : function(action, params, success, fail) {

        if(!action){
            throw 'No Action'
        }

        action.setParams(params)

        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                $A.log("Success", a.getReturnValue())
                if (success){
                    success.apply(this, [a.getReturnValue()])
                }
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError())
                if(fail){
                    fail.apply(this, [a.getError()])
                } else {
                    var error = a.getError()
                    console.error('callApex error',error)
                    if(error && error.length){
                        alert(error[0].message)
                    } else {
                        throw error
                    }
                }
            }
        });

        $A.enqueueAction(action)

    },

    callBackgroundApex : function(action, params, success, fail) {
        if(!action){
            throw 'No Action'
        }

        action.setParams(params);
        action.setBackground();

        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                $A.log("Success", a.getReturnValue())
                if (success){
                    success.apply(this, [a.getReturnValue()])
                }
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError())
                if(fail){
                    fail.apply(this, [a.getError()])
                } else {
                    var error = a.getError()
                    console.error('callApex error',error)
                    if(error && error.length){
                        alert(error[0].message)
                    } else {
                        throw error
                    }
                }
            }
        });

        $A.enqueueAction(action)

    },

    b64toBlob : function(b64Data, contentType, sliceSize){
        contentType = contentType || '';
        sliceSize = sliceSize || 512;

        var byteCharacters = atob(b64Data);
        var byteArrays = [];

        for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
            var slice = byteCharacters.slice(offset, offset + sliceSize);

            var byteNumbers = new Array(slice.length);
            for (var i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }

            var byteArray = new Uint8Array(byteNumbers);

            byteArrays.push(byteArray);
        }

        var blob = new Blob(byteArrays, {type: contentType});
        return blob;
    },

    showToast: function (params) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams(params);
            toastEvent.fire();
        } else {
            throw 'No Toast'
        }
    }
})