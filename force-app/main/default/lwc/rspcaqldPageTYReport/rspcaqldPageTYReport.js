import {LightningElement} from 'lwc';
import PAGE_FILES from "@salesforce/contentAssetUrl/TYReportPagezip";
import * as constants from 'c/constants';

export default class RspcaqldPageTyReport extends LightningElement {
    headerImage = PAGE_FILES + "?pathinarchive=header-image.png";
    pageActions = PAGE_FILES + "?pathinarchive=page-actions.jpeg";
    tigerLeftPaw = constants.tigerLeftPaw;

    report = {
        type: 'information',
        date: 'February 23, 2023',
        location: 'Carey’s cage farm',
        witnessedTime: '12:30pm',
        witnessedDate: 'Friday, 12 Dec 2022',
        uploads: [
            {key: 0, imageUrl: PAGE_FILES + "?pathinarchive=upload-1.jpeg"},
            {key: 1, imageUrl: PAGE_FILES + "?pathinarchive=upload-2.jpeg"},
            {key: 2, imageUrl: PAGE_FILES + "?pathinarchive=upload-3.jpeg"},
            {key: 3, imageUrl: PAGE_FILES + "?pathinarchive=upload-4.jpeg"}
        ]
    };

    contact = {
        name: 'Mr David Sample',
        email: 'customer@email.com',
        phone: '(+61) 400 234 456'
    };
    secondContact = {
        name: 'Jenny Sample',
        phone: '0400 123 124'
    };
}