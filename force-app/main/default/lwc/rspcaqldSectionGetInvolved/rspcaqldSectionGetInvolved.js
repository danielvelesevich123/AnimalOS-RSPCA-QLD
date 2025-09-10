import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, LightningElement, wire} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldSectionGetInvolved extends LightningElement {
    @api customClass;
    officialRSPCAPaw = constants.officialRSPCAPaw;

    @api header = "Get involved &<br>help make a difference";

    @api imageOne;
    imageOneKey;
    @wire(getImage, {contentKey: '$imageOneKey'}) imageOneContentURL;
    @api sectionOneHeader = 'Volunteer your time';
    @api sectionOneLinkOneIcon;
    @wire(getImage, {contentKey: '$sectionOneLinkOneIcon'}) sectionOneLinkOneIconURL;
    @api sectionOneLinkOneLabel = 'Volunteer';
    @api sectionOneLinkOneUrl = 'Volunteer';
    @api sectionOneLinkTwoIcon;
    @wire(getImage, {contentKey: '$sectionOneLinkTwoIcon'}) sectionOneLinkTwoIconURL;
    @api sectionOneLinkTwoLabel = 'Foster an animal';
    @api sectionOneLinkTwoUrl;
    @api sectionOneLinkThreeIcon;
    @wire(getImage, {contentKey: '$sectionOneLinkThreeIcon'}) sectionOneLinkThreeIconURL;
    @api sectionOneLinkThreeLabel = 'Attend an event';
    @api sectionOneLinkThreeUrl;
    @api sectionOneLinkFourLabel = 'View all ways to get involved';
    @api sectionOneLinkFourUrl = 'get-involved';

    @api imageTwo;
    imageTwoKey;
    @wire(getImage, {contentKey: '$imageTwoKey'}) imageTwoContentURL;
    @api sectionTwoHeader = 'Make a donation';
    @api sectionTwoLinkOneIcon;
    @wire(getImage, {contentKey: '$sectionTwoLinkOneIcon'}) sectionTwoLinkOneIconURL;
    @api sectionTwoLinkOneLabel = 'Make a one-off donation';
    @api sectionTwoLinkOneUrl;
    @api sectionTwoLinkTwoIcon;
    @wire(getImage, {contentKey: '$sectionTwoLinkTwoIcon'}) sectionTwoLinkTwoIconURL;
    @api sectionTwoLinkTwoLabel = 'Leave a gift in your will';
    @api sectionTwoLinkTwoUrl;
    @api sectionTwoLinkThreeIcon;
    @wire(getImage, {contentKey: '$sectionTwoLinkThreeIcon'}) sectionTwoLinkThreeIconURL;
    @api sectionTwoLinkThreeLabel = 'Fundraising event';
    @api sectionTwoLinkThreeUrl;
    @api sectionTwoLinkFourLabel = 'See where your donation goes';
    @api sectionTwoLinkFourUrl;

    @api isAdvertisement = false;
    @api advertisementImage;
    @api advertisementHeader = 'Shop RSPCA';
    @api advertisementDescription = '100% of profits go towards animal care';
    @api advertisementLinkLabel = 'Learn more';
    @api advertisementLink;
    @api advertisementLogoOneKey;
    @api advertisementLogoTwoKey;

    get mainClass() {
        return 'page-home-involve shape-3' + (this.customClass ? ' action-header-navigation-block ' + this.customClass : '');
    }

    get imageOneUrl() {
        return this.handleImage(this.imageOne, 1);
    }
    get imageTwoUrl() {
        return this.handleImage(this.imageTwo, 2);
    }

    handleImage(image, count) {
        if (image) {
            if (!image.includes('http') && !image.includes('jpeg') && !image.includes('jpg') && !image.includes('png')) {
                if (count == 1) {this.imageOneKey = image;} else {this.imageTwoKey = image;}
                return count == 1 ? this.imageOneContentURL.data : this.imageTwoContentURL.data;
            } else {
                return image;
            }
        }
        return null;
    }
}