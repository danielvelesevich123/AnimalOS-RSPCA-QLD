import {api, LightningElement} from 'lwc';
import * as constants from 'c/constants';

export default class RspcaqldNavigationBreadcrumb extends LightningElement {
    @api parents;
    @api current;
    @api breadcrumbBlack = false;
    buildingWhite = constants.buildingWhite;
    buildingDark = constants.buildingDark;

    get isCurrent() {
        return this.current ? true : false;
    }

    get buildingIcon() {
        return this.breadcrumbBlack ? this.buildingDark : this.buildingWhite;
    }

    get mainClass() {
        return 'navigation-breadcrumb' + (this.breadcrumbBlack ? ' black' : '');
    }
}