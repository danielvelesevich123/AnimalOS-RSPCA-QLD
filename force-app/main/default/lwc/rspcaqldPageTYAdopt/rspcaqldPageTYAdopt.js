import {LightningElement} from 'lwc';
import PAGE_FILES from "@salesforce/contentAssetUrl/PortalImageszip";
import * as constants from 'c/constants';

export default class RspcaqldPageWelfareService extends LightningElement {
    headerImage = PAGE_FILES + "?pathinarchive=ty-adopt-header-image.png";
    tigerLeftPaw = constants.tigerLeftPaw;
    pet = {
        key: 0,
        address: 'Darabin, Brisbane',
        imageURL: PAGE_FILES + "?pathinarchive=ty-adopt-pet-image.jpeg",
        name: 'Cotton',
        keyWords: 'Lazy Dork',
        breed: 'Greyhound',
        iconName: 'fa-solid fa-dog',
        details: 'Gender, Age, Size',
        gender: 'Gender',
        ageGroup: 'Age',
        size: 'Size'
    };
    contact = {
        name: 'David Sampler',
        email: 'dsampler@email.com',
        phone: '0400 123 123'
    };
    secondContact = {
        name: 'Nelly Neighbour',
        email: 'nneighbour@email.com',
        phone: '0400 123 123'
    };
}