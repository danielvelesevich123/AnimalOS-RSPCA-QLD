public with sharing class ShelterBuddyService {
    public static void mapShelterBuddyToSobject(Map<SObjectField, String> SFToShelterBuddyMap, vertic_DTO dto, SObject recordVar) {
        for (SObjectField SFField : SFToShelterBuddyMap.keySet()) {
            String path = SFToShelterBuddyMap.get(SFField);
            Object shelterBuddyFieldValue;
            DisplayType fieldType = SFField.getDescribe().getType();
            if (fieldType == DisplayType.DATE) {
                String dateStr = dto.getString(path);
                shelterBuddyFieldValue = vertic_Utils.dates.parseDatetimeAnyFormat(dateStr, 'yyyy-MM-ddTHH:mm:ssZ', true)?.date();
            } else if(fieldType == DisplayType.BOOLEAN) {
                shelterBuddyFieldValue = dto.getBoolean(path) == true;
            } else if(fieldType == DisplayType.DOUBLE || fieldType == DisplayType.INTEGER || fieldType == DisplayType.LONG || fieldType == DisplayType.CURRENCY) {
                shelterBuddyFieldValue = dto.getDecimal(path);
            } else if (fieldType == DisplayType.DATETIME) {
                String dateStr = dto.getString(path);
                if (String.isNotBlank(dateStr)) {
                    shelterBuddyFieldValue = vertic_Utils.dates.parseDatetimeAnyFormat(dateStr, 'yyyy-MM-ddTHH:mm:ssZ', true);
                } else {
                    shelterBuddyFieldValue = null;
                }
            } else {
                System.debug('path: ' + path);
                shelterBuddyFieldValue = dto.getString(path);
            }
            recordVar.put(SFField, shelterBuddyFieldValue);
        }
    }
}