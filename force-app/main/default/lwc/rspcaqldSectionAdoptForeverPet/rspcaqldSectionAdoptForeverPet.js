import {api, LightningElement} from 'lwc';
import PAGE_FILES from "@salesforce/contentAssetUrl/PortalImageszip";
import * as constants from 'c/constants';

export default class RspcaqldSectionAdoptForeverPet extends LightningElement {
    @api customClass;
    @api header = 'Looking to adopt a forever pet?';
    @api subheader = 'Find for an animal in need of a home';
    @api dogsString;
    @api puppiesString;
    @api catsString;
    @api kittensString;
    @api reptilesString;
    @api farmYardString;
    @api smallAnimalsString;
    @api birdsString;
    @api browseAllAnimalsString;
    officialRSPCAPaw = constants.officialRSPCAPaw;

    petsImages = {
        dogs: PAGE_FILES + "?pathinarchive=dogs.png",
        puppies: PAGE_FILES + "?pathinarchive=puppies.png",
        cats: PAGE_FILES + "?pathinarchive=cats.png",
        kittens: PAGE_FILES + "?pathinarchive=kittens.png",
        reptilies: PAGE_FILES + "?pathinarchive=reptilies.png",
        farmyard: PAGE_FILES + "?pathinarchive=farm-yard.png",
        smallanimals: PAGE_FILES + "?pathinarchive=small-animals.png",
        birds: PAGE_FILES + "?pathinarchive=birds.png"
    }

    get mainClass() {
        return 'page-home-pets shape-3' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get browseAllAnimalsLink() {return this.createLink(this.browseAllAnimalsString, '');}
    get dogsLink() {return this.createLink(this.dogsString, '?type=dog');}
    get puppiesLink() {return this.createLink(this.puppiesString, '?type=puppy');}
    get catsLink() {return this.createLink(this.catsString, '?type=cat');}
    get kittensLink() {return this.createLink(this.kittensString, '?type=kitten');}
    get reptilesLink() {return this.createLink(this.reptilesString, '?type=reptile');}
    get farmyardLink() {return this.createLink(this.farmYardString, '?type=farmyard');}
    get smallAnimalsLink() {return this.createLink(this.smallAnimalsString, '?type=smallanimal');}
    get birdsLink() {return this.createLink(this.birdsString, '?type=bird');}

    createLink(linkString, type) {
        let link = {};
        if (linkString) {
            link = JSON.parse(linkString);
            let urlPrefix = link.url ? (link.url.startsWith('/') ? '..' : '../') : '';
            link.url = link.url ? urlPrefix + link.url + type : '';
        }
        return link;
    }
}