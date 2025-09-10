public class FormatService {

    public static void format(List<SObject> records) {
        if (records == null || records.isEmpty()) {
            return;
        }

        SObjectType sObjectTypeVar = records[0].getSObjectType();

        if (sObjectTypeVar == Contact.SObjectType) {
            format((List<Contact>) records);
        }
    }

    public static void format(List<Contact> contacts) {
        for (Contact contact : contacts) {
            contact.MiddleName = contact.MiddleName != null ? contact.MiddleName.replace('.', '') : null;
            contact.Email = contact.Email != null ? contact.Email.toLowerCase() : null;
            contact.MailingCity = vertic_Utils.strings.capitalizeAllWords(contact.MailingCity);
            contact.MailingState = AddressService.formatState(contact.MailingState);
            contact.MailingCountry = AddressService.formatCountry(contact.MailingCountry);
            splitStreet(contact);
        }

        vertic_Utils.IPhoneNumberFormatter mobileFormatter = new FormatService.MobilePhoneNumberFormatter();
        vertic_Utils.IPhoneNumberFormatter homeFormatter = new vertic_Utils.HomePhoneNumberFormatter();
        Map<Schema.sObjectField, vertic_Utils.IPhoneNumberFormatter> formatMapping = new Map<Schema.sObjectField, vertic_Utils.IPhoneNumberFormatter>{
                Contact.MobilePhone.getDescribe().getSobjectField() => mobileFormatter,
                Contact.HomePhone.getDescribe().getSobjectField() => homeFormatter,
                Contact.npe01__WorkPhone__c.getDescribe().getSobjectField() => homeFormatter,
                Contact.OtherPhone => homeFormatter
        };
        vertic_Utils.formats.formatPhoneNumbers(contacts, formatMapping, true);
    }

    private static void splitStreet(Contact contact) {
        if (String.isNotBlank(contact?.MailingStreet)) {
            List<String> lines = new List<String>();

            if (contact.MailingStreet.contains('\r\n')) {
                lines = contact.MailingStreet.split('\r\n');
            } else if (contact.MailingStreet.contains('\n')) {
                lines = contact.MailingStreet.split('\n');
            }

            if (lines.size() > 1) {
                contact.Mailing_Street_Line_1__c = lines[0];
                contact.Mailing_Street_Line_2__c = lines[1];
            } else {
                contact.Mailing_Street_Line_1__c = contact.MailingStreet;
            }
        }
    }

    public class MobilePhoneNumberFormatter implements vertic_Utils.IPhoneNumberFormatter {
        public String format(String phone) {
            if (String.isNotBlank(phone)) {
                if (phone.startsWith('04')) {
                    phone = phone.replaceFirst('04', '\\+614');
                } else if (phone.startsWith('+6104')) {
                    phone = phone.replaceFirst('\\+6104', '\\+614');
                } else if (phone.startsWith('+61 4')) {
                    phone = phone.replaceFirst('\\+61 4', '\\+614');
                } else if (phone.startsWith('6104')) {
                    phone = phone.replaceFirst('6104', '\\+614');
                } else if (phone.startsWith('614')) {
                    phone = '+' + phone;
                } else if (phone.startsWith('61 4')) {
                    phone = phone.replaceFirst('61 4', '\\+614');
                }

                if (phone.startsWith('+614')) {
                    String phoneFormatted = vertic_Utils.strings.removeNonNumeric(phone);
                    phoneFormatted = '+' + phoneFormatted.replaceFirst('^(\\d{0,5})(\\d{0,3})(\\d{0,3})(\\d*)$', '$1 $2 $3 $4');

                    return phoneFormatted.trim();
                }
            }

            return phone;
        }
    }
}