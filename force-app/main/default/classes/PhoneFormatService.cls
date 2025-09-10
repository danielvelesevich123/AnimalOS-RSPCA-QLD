public without sharing class PhoneFormatService {

    public static String formatPhone(String inputPhone) {
        if (inputPhone == null) {
            return null;
        }

        String phoneDigitsOnly = inputPhone.replaceAll('[^0-9]', '');

        if (String.isBlank(phoneDigitsOnly)) {
            return null;
        }

        if (phoneDigitsOnly.length() < 9) {
            throw new vertic_Structs.CommonException(phoneDigitsOnly + ' Mobile Phone cant contain less than 9 digits');
        } else if (phoneDigitsOnly.length() > 11) {
            throw new vertic_Structs.CommonException(phoneDigitsOnly + ' Mobile Phone cant contain mare than 11 digits');
        }

        if (phoneDigitsOnly.length() == 9) {
            return formatPhoneWithNineDigits(phoneDigitsOnly);
        }

        if (phoneDigitsOnly.length() == 10) {
            return formatPhoneWithTenDigits(phoneDigitsOnly);
        }

        if (phoneDigitsOnly.length() == 11) {
            return formatPhoneWithElevenDigits(phoneDigitsOnly);
        }

        return null;
    }

    private static String formatPhoneWithNineDigits(String phoneVar) {
        phoneVar = '0' + phoneVar;

        return phoneVar.left(2) == '04'
                ? replaceWithFourThreeThree(phoneVar)
                : replaceWithTwoFourFour(phoneVar);
    }

    private static String formatPhoneWithTenDigits(String phoneVar) {

        if (
            phoneVar.left(1) != '0'
            && phoneVar.left(4) != '1300'
            && phoneVar.left(4) != '1800'
        ) {
            throw new vertic_Structs.CommonException(phoneVar + ' Invalid value, phone number must start with "0", "1300" or "1800"');
        }

        return phoneVar.left(2) == '04'
                || phoneVar.left(4) == '1300'
                || phoneVar.left(4) == '1800'
                    ? replaceWithFourThreeThree(phoneVar)
                    : replaceWithTwoFourFour(phoneVar);
    }

    private static String formatPhoneWithElevenDigits(String phoneVar) {
        String formattedPhone;

        if (phoneVar.left(2) != '61' && phoneVar.left(1) != '0') {
            throw new vertic_Structs.CommonException(phoneVar + ' Invalid value, phone number must start with "0"');
        }

        if (phoneVar.left(2) == '61') {
            phoneVar = '0' + phoneVar.removeStart('61');

            if (phoneVar.left(2) == '04') {
                formattedPhone = replaceWithFourThreeThree(phoneVar);
            } else {
                formattedPhone = replaceWithTwoFourFour(phoneVar);
            }
        } else {
            formattedPhone = replaceWithThreeFourFour(phoneVar);
        }

        return formattedPhone;
    }

    // 0412 345 678
    private static String replaceWithFourThreeThree(String phoneVar) {
        return phoneVar.replaceFirst('^(\\d{0,4})(\\d{0,3})(\\d{0,3})$', '$1 $2 $3');
    }

    // 01 2345 6789
    private static String replaceWithTwoFourFour(String phoneVar) {
        return phoneVar.replaceFirst('^(\\d{0,2})(\\d{0,4})(\\d{0,4})$', '$1 $2 $3');
    }

    // 012 3456 7890
    private static String replaceWithThreeFourFour(String phoneVar) {
        return phoneVar.replaceFirst('^(\\d{0,3})(\\d{0,4})(\\d{0,4})$', '$1 $2 $3');
    }

}