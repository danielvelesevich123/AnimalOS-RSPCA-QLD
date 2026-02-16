import {api, LightningElement, wire} from 'lwc';
import BaseElement, {showToast} from "c/verticBase";
import {loadStyle, loadScript} from 'lightning/platformResourceLoader';
import smartcropLib from '@salesforce/resourceUrl/smartcrop';
import LightningConfirm from 'lightning/confirm';
import PLACEHOLDER_URL from "@salesforce/resourceUrl/animalos__ImagePlaceholder";

export default class VerticPhoto extends BaseElement {
    smartcropVar;

    @api recordId;
    @api loadOneDrive;
    @api createAttachment;
    @api driveString;
    @api folderNamePostfix;
    @api recordPage;
    @api showHelpText = false;
    @api removeUploadButton = false;
    placeholderUrl = PLACEHOLDER_URL;


    connectedCallback() {
        super.connectedCallback();
        this.doInit({
                recordId: this.recordId,
                loadOneDrive: this.loadOneDrive,
                driveName: this.driveString,
                folderNamePostfix: this.folderNamePostfix
            },
            'vertic_PhotoMetaProc')
            .then((response) => {
                this.meta.dto.photoUrl = response.dto.photoUrl;
                this.meta = this.meta;
            })
            .catch(errors => {
                showToast(this, 'Error', errors[0].message, 'error');
            });

        Promise.all([
            loadScript(this, smartcropLib + '/src/smartcrop.js'),
            loadScript(this, smartcropLib + '/src/jquery.min.js')
        ]).then(() => {
            this.smartcropVar = smartcrop;
        }).catch((ex) => {
            showToast(this, 'Error', 'Script load error: ' + ex, 'error');
        })
    }

    get buttonClass() {
        return this.showHelpText ? 'upload-photo-button' : '';
    }

    handleCurrentFileChange(event) {
        let file = event.target.files[0];
        if (file.size > 4194304) { // Max file size 4 MB
            showToast(this, 'Error', 'File size cannot exceed 4 MB. Selected file size is ' + (file.size / 1024 / 1024).toFixed(1) + ' MB.', 'error');
            return;
        }

        this.isBusy = true;

        let reader = new FileReader();
        reader.onload = (e) => {

            let img = new Image();
            let binaryString = reader.result;
            img.src = binaryString;

            this.meta.dto.photoUrl_old = this.meta.dto.photoUrl;
            this.meta.dto.photoUrl = null;

            img.onload = (e) => {
                this.isBusy = false;

                this.crop(binaryString)
                    .then((binaryResult) => {
                        let request = {
                            loadOneDrive: this.loadOneDrive,
                            createAttachment: this.createAttachment,
                            driveName: this.driveString,
                            folderNamePostfix: this.folderNamePostfix,
                            recordId: this.recordId,
                            prefix: this.prefix,
                            base64Data: encodeURIComponent(binaryResult.substring(binaryResult.indexOf('base64,') + 7)),
                            fileName: 'Profile Image ' + file.name,
                            contentType: file.type
                        };
                        this.execute(
                            'vertic_PhotoSubmitProc',
                            request
                        ).then((response) => {
                            this.meta.dto.photoUrl = response.dto.photoUrl;
                            this.meta.dto.oneDriveFileId = response.dto.oneDriveFileId;
                            this.meta.dto.driveId = response.dto.driveId;
                            this.meta.dto.oneDriveId = response.dto.oneDriveId;
                            this.meta = this.meta;
                        });
                    }).catch((ex) => {
                    showToast(this, 'Error', 'Upload Proc error: ' + ex, 'error');

                });
            }

            img.onload.bind(this.recordId, this.isBusy, this.crop, this.recordId, this.prefix, this.loadOneDrive, this.createAttachment, this.driveString, this.folderNamePostfix);
        }
        reader.onload.bind(this.meta);
        reader.readAsDataURL(file);
    }

    handlePhotoClick(event) {
        this.template.querySelector('[data-id="fileInput"]').click();
    }

    crop(binary) {
        return new Promise((resolve, reject) => {
            if (binary) {
                let blob = new Blob([new Uint8Array(binary)]);
                let image = new Image();

                image.onload = ((e) => {

                    let canvas = document.createElement('canvas');
                    let ctx = canvas.getContext('2d');
                    ctx.clearRect(0, 0, canvas.width, canvas.height);

                    let mimSide = image.height > image.width ? image.width : image.height;
                    mimSide = mimSide > 1000 ? 1000 : mimSide;

                    canvas.width = mimSide;
                    canvas.height = mimSide;

                    this.smartcropVar.crop(image, {width: mimSide, height: mimSide}).then((result) => {

                        ctx.drawImage(image,
                            result.topCrop.x,
                            result.topCrop.y,
                            result.topCrop.width,
                            result.topCrop.height,
                            0, 0,
                            canvas.width,
                            canvas.height
                        );

                        ctx.canvas.toBlob((blob) => {
                            let reader = new FileReader();
                            reader.readAsDataURL(blob);
                            reader.onloadend = function () {
                                let base64data = reader.result;
                                resolve(base64data);
                            }
                        });

                    });
                    return resolve;
                });

                image.onload.bind(this.smartcropVar);
                image.src = binary;
            }
        });
    }

    async handleRemoveProfileImageClick() {
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to remove the Profile Image?'
        });
        let oneDriveFileId = this.meta.dto.oneDriveFileId;

        if (result) {
            this.execute(
                'vertic_DMLProc',
                {
                    sObjectType: 'OneDrive_File__c',
                    upsert: [{
                        Id: oneDriveFileId,
                        Profile_Image__c: false,
                        Is_Deleted__c: true
                    }]
                })
                .then(response => {
                    this.meta.dto.photoUrl = 'https://s3-us-west-1.amazonaws.com/sfdc-demo/image-placeholder.png';
                    this.meta.dto.oneDriveFileId = null;
                    this.meta = this.meta;


                    if (this.meta.dto.driveId && this.meta.dto.oneDriveId) {
                        let year = new Date().getFullYear();
                        let month = new Date().getMonth() + 1;
                        let day = new Date().getDate();


                        let date = year + '' + (month < 10 ? '0' + month : month) + '' + day;

                        this.execute(
                            'aos_HttpRequestProc',
                            {
                                method: 'PUT',
                                endpoint: 'callout:OneDrive/drives/' + encodeURIComponent(this.meta.dto.driveId) + '/items/' + encodeURIComponent(this.meta.dto.oneDriveId),
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Accept': 'application/json'
                                },
                                body: JSON.stringify({
                                    "name": "DELETED_" + date + "_" + this.meta.dto.fileName
                                })
                            }
                        )
                    }
                })
        }
    }

    get uploadEnabled() {
        return this.removeUploadButton === false;
    }
}