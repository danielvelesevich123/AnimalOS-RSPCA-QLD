import getImage from '@salesforce/apex/ManagedContentService.getImageByContentKey';
import {api, wire, LightningElement} from 'lwc';
import * as constants from 'c/constants';
import {MessageContext, publish} from "lightning/messageService";
import {CurrentPageReference, NavigationMixin} from "lightning/navigation";
import headerAction from '@salesforce/messageChannel/HeaderAction__c';
import {getRecord} from "lightning/uiRecordApi";

const CAMPAIGN_FIELDS = ["Campaign.ExpectedRevenue", "Campaign.AmountWonOpportunities"];

export default class RspcaqldSectionCampaignHeader extends LightningElement {
    @api recordId;
    @api header;
    @api headerHeight;
    @api imageHeight;
    @api description;
    @api buttonColor;
    @api buttonLabel;
    @api buttonLabelColor = '#FFFFFF';
    @api buttonClass;
    @api buttonLink;
    @api buttonIcon;
    @api displayProgressBar = 'Yes';
    @wire(getImage, {contentKey: '$buttonIcon'}) buttonIconURL;
    @api imageUrl;
    @api imageKey;
    @wire(getImage, {contentKey: '$imageKey'}) imageContentURL;
    @api logoKey;
    @wire(getImage, {contentKey: '$logoKey'}) logoContentURL;
    @api pawPrintLabel;
    @api campaignGoalHeader;
    @wire(getRecord, { recordId: "$recordId", fields: CAMPAIGN_FIELDS}) campaign;

    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    pageReference({state}) {
        if (state && state.id) this.recordId = state.id;
    }

    @wire(MessageContext)
    messageContext;

    get isLogo() {
        return this.logoContentURL.data ? true : false;
    }
    get isHeader() {return this.header ? true : false;}
    get isDescription() {return this.description ? true : false;}

    get isDisplayProgressBar() {return this.displayProgressBar == 'Yes' ? true : false;}

    get expectedRevenue() {
        return this.campaign && this.campaign.data ? this.campaign.data.fields.ExpectedRevenue.value : 0;
    }

    get amountWonOpportunities() {
        return this.campaign && this.campaign.data ? this.campaign.data.fields.AmountWonOpportunities.value : 0;
    }

    get imageStyle() {
        return this.imageHeight ? 'height: ' + this.imageHeight + 'px' : '';
    }

    get buttonStyle() {
        return (this.buttonColor ? 'background: ' + this.buttonColor  + '; ' : '') + (this.buttonLabelColor ? 'color: ' + this.buttonLabelColor + ';' : '');
    }

    get isButtonLink() {
        return this.buttonLink ? true : false;
    }

    get image(){
        return this.imageContentURL.data ? this.imageContentURL.data : (this.imageUrl ? this.imageUrl : null);
    }

    get pawPrint() {
        return this.pawPrintLabel ? constants.officialRSPCAPaw : null;
    }
    get pawPrintClass() {
        return 'paw-print' + (this.pawPrintLabel ? (this.pawPrintLabel == 'Official RSPCA Left' ? '' : ' paw-right') : null);
    }

    get headerStyle() {
        return this.headerHeight ? 'height: ' + this.headerHeight + 'px' : '';
    }

    handleDonationScroll(evt) {
        publish(this.messageContext, headerAction, {class: this.buttonClass ? this.buttonClass : 'page-cta-form'});
    }
}