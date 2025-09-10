import {LightningElement} from 'lwc';
import getContent from '@salesforce/apex/rspcaqldUtils.getContentData';

export default class RspcaqldFileUpload extends LightningElement {
    get acceptedFormats() {
        return ['.jpeg', '.jpg', '.png'];
    }

    handleUploadFinished(event) {
        this.sendEvent(event.detail.files);
    }

    sendEvent(uploadedFiles) {
        let contentVersionIds = [];
        for (let i = 0; i < uploadedFiles.length; i++) {
            contentVersionIds.push(uploadedFiles[i].contentVersionId);
        }

        getContent({ ids: contentVersionIds})
            .then(result => {
                for (let i = 0; i < uploadedFiles.length; i++) {
                    uploadedFiles[i].fileURL = 'data:image/bmp;base64,' + result[uploadedFiles[i].contentVersionId];
                }

                this.dispatchEvent(new CustomEvent("addfile", {
                    detail: {
                        files : uploadedFiles
                    }
                }));
            })
            .catch(error => {});
    }

    // handleOpen(evt) {
    //     this.template.querySelector('input').click();
    // }
    //
    // handleHiddenFileChange(evt) {
    //     var newFiles = evt.target.files;
    //     this.readFiles(newFiles);
    // }
    //
    // readFiles(newFiles) {
    //     let fullSize = 0;
    //     for (let i = 0; i < newFiles.length; i++) {
    //         fullSize += newFiles[i].size;
    //     }
    //
    //     if (fullSize > 30 * 1024 * 1024) {
    //         this.showToast('The maximum file size is 30 MB.');
    //         return;
    //     }
    //
    //     for (var i = 0; i < newFiles.length; i++) {
    //         var that = this;
    //         let newFile = new Object();
    //         newFile.fileName = newFiles[i].name;
    //         newFile.fileType = newFiles[i].type;
    //
    //         let reader = new FileReader();
    //         reader.onloadend = function () {
    //             newFile.fileURL = reader.result;
    //             newFile.dataURL = reader.result.match(/,(.*)$/)[1];
    //             setTimeout(() => that.sendEvent(that, newFile), 150);
    //         }
    //         reader.readAsDataURL(newFiles[i]);
    //     }
    // }
    //

    //
    // showToast(message) {
    //     let event = new ShowToastEvent({
    //         title: 'Error',
    //         message: message,
    //         variant: 'error'
    //     });
    //     this.dispatchEvent(event);
    // }
}