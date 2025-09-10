import {api, LightningElement} from 'lwc';

export default class RspcaqldSectionTyDonation extends LightningElement {
    @api header = 'Your donation details';
    @api mistakeString = '<h5>Made a mistake?</h5><p className="xmedium">Contact our team by emailing</p><a href="mailto:supportercare@rspcaqld.org.au">supportercare@rspcaqld.org.au</a>';
    metadata;

    connectedCallback() {
        let cookieString = this.getCookie('ty_donation');
        this.metadata = cookieString ? JSON.parse(decodeURI(cookieString)) : {};
        this.metadata.total = this.metadata.total ? (this.metadata.total.toString().includes('.') ? this.metadata.total : this.metadata.total + '.00') : '0.00';
        this.metadata.date = new Date();
        this.metadata.donation_type_label = this.metadata.donation_type == "monthly" ? 'Monthly' : 'One-off';
        this.metadata.is_monthly_donation = this.metadata.donation_type == "monthly";
        this.metadata.is_organisation = this.metadata.organisation ? true : false;
    }

    getCookie(name) {
        var cookieString = "; " + document.cookie;
        var parts = cookieString.split("; " + name + "=");
        if (parts.length === 2) {
            return parts.pop().split(";").shift();
        }
        return null;
    }
}