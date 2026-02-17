import {api} from 'lwc';
import AosBase, {showToast} from "c/aosBase";

export default class AosFileUpload extends AosBase {

    @api recordId
    @api required;
    @api label;
    @api acceptedFormats;
    @api driveName;
    @api folderFieldName;
    @api fileFieldName;
    @api fileNamePrefix;
    @api fileNamePostfix;
    @api fileId;
    fileName;
    downloadUrl;

    connectedCallback() {
        super.connectedCallback();
        this.doInit({
                recordId: this.recordId,
                driveName: this.driveName,
                folderFieldName: this.folderFieldName,
                fileFieldName: this.fileFieldName,
                fileNamePrefix: this.fileNamePrefix,
                fileNamePostfix: this.fileNamePostfix
            },
            'aos_FileUploadMetaProc')
            .then((response) => {
                this.fileId = response.dto.fileId;
                this.fileName = response.dto.fileName;
                this.downloadUrl = response.dto.downloadUrl;
            })
            // .then(() =>{
            //     if(this.meta.sessionUrl != null){
            //         console.log(typeof(this.meta.file));
            //         let arrayVar = new Uint8Array(this.meta.file);
            //
            //         let size = arrayVar.length;
            //         let chunks = [];
            //         let countOfChunks = Math.ceil(size / chunkSize);
            //
            //         for (let i = 0; i < countOfChunks; i++) {
            //             let start = i * chunkSize;
            //             let end = Math.min(start + chunkSize, size);
            //             chunks.push({
            //                 start: start,
            //                 end: end,
            //                 blob: new Blob([arrayVar.slice(start, end)])
            //             });
            //         }
            //         console.log(chunks);
            //         return (chunks);
            //     }
            // })
            .catch(errors => {
                showToast(this, 'Error', errors[0].message, 'error');
            });
    }

    handleUploadFinished(event) {
        let file = event.detail.files[0];

        let request = {
            recordId: this.recordId,
            driveName: this.driveName,
            folderFieldName: this.folderFieldName,
            fileFieldName: this.fileFieldName,
            fileNamePrefix: this.fileNamePrefix,
            fileNamePostfix: this.fileNamePostfix,
            documentId: file.documentId
        }

        this.execute(
            'aos_FileUploadSubmitProc',
            request
        ).then((response) => {
            this.fileId = response.dto.fileId;
            this.fileName = response.dto.fileName;
            this.downloadUrl = response.dto.downloadUrl;
            this.dispatchEvent(new CustomEvent('change', {
                bubbles: false,
                composed: false,
                detail: {
                    value: response.dto.fileId
                }
            }));
        }).catch(errors => {
            showToast(this, 'Error', errors[0].message, 'error');
        });
    }

    @api
    validate() {
        return this.required && this.fileId;
    }
}