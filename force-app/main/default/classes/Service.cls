public with sharing class Service {

    private static final Set<DisplayType> TEXT_DISPLAY_TYPES = new Set<DisplayType>{
            DisplayType.ADDRESS, DisplayType.ANYTYPE, DisplayType.BASE64, DisplayType.COMBOBOX,
            DisplayType.EMAIL, DisplayType.ENCRYPTEDSTRING, DisplayType.ID, DisplayType.JSON,
            DisplayType.MULTIPICKLIST, DisplayType.PHONE, DisplayType.PICKLIST,
            DisplayType.REFERENCE, DisplayType.STRING, DisplayType.TEXTAREA, DisplayType.URL
    };

    public static Operator parseOperator(String operatorStr) {
        return Operator.valueOf(operatorStr?.replace(' ', '_')?.toUpperCase());
    }
    public static String operator2string(Operator operatorInput) {
        return (operatorInput + '').replace('_', ' ').toLowerCase();
    }
    public static DisplayType parseType(String type) {
        return DisplayType.valueOf(type?.replace(' ', '_')?.toUpperCase());
    }

    public static Map<Operator, String> OPERATOR_TO_STRING = new Map<Operator, String>{
            Operator.EQUALS => '=', Operator.NOT_EQUAL_TO => '!=',
            Operator.LESS_THAN => '<', Operator.GREATER_THAN => '>',
            Operator.LESS_OR_EQUAL => '<=', Operator.GREATER_OR_EQUAL => '>=',
            Operator.CONTAINS => 'LIKE', Operator.DOES_NOT_CONTAIN => 'LIKE',
            Operator.STARTS_WITH => 'LIKE', Operator.ENDS_WITH => 'LIKE'
    };

    public static String createQueryCondition(String field, String type, String operator, Object value) {
        return createQueryCondition(field, parseType(type), parseOperator(operator), value);
    }
    public static String createQueryCondition(String field, String type, Operator operatorInput, Object value) {
        return createQueryCondition(field, parseType(type), operatorInput, value);
    }
    public static String createQueryCondition(String field, DisplayType type, String operator, Object value) {
        return createQueryCondition(field, type, parseOperator(operator), value);
    }
    public static String createQueryCondition(String field, DisplayType type, Operator operatorInput, Object value) {

        String textQuoteMark = '';
        String textPercentStartMark = '';
        String textPercentEndMark = '';
        String notOperator = operatorInput == Operator.DOES_NOT_CONTAIN ? 'NOT' : '';
        String operatorStr = OPERATOR_TO_STRING.get(operatorInput);
        if (value instanceof List<Object>) {
            if (type == DisplayType.MULTIPICKLIST) {
                notOperator = '';
                operatorStr = operatorInput == Operator.NOT_EQUAL_TO || operatorInput == Operator.DOES_NOT_CONTAIN ? 'EXCLUDES' : 'INCLUDES';
            } else {
                notOperator = operatorInput == Operator.NOT_EQUAL_TO || operatorInput == Operator.DOES_NOT_CONTAIN ? 'NOT' : notOperator;
                operatorStr = 'IN';
            }
            List<String> values = new List<String>();
            for (Object item : (List<Object>) value) {
                item = item instanceof String ? '\'' + item + '\'' : item;
                values.add(String.valueOf(item));
            }
            value = '(' + String.join(values, ', ') + ')';
        } else if (TEXT_DISPLAY_TYPES.contains(type)) {
            textQuoteMark = '\'';
            if (operatorInput == Operator.CONTAINS || operatorInput == Operator.DOES_NOT_CONTAIN) {
                textPercentStartMark = textPercentEndMark = '%';
            } else if (operatorInput == Operator.ENDS_WITH) {
                textPercentStartMark = '%';
            } else if (operatorInput == Operator.STARTS_WITH) {
                textPercentEndMark = '%';
            }
        }
        return String.format('{0} {1} {2} {3}', new List<String>{
                notOperator,
                field,
                operatorStr,
                value == null ? 'NULL' : textQuoteMark + textPercentStartMark + String.valueOf(value) + textPercentEndMark + textQuoteMark
        }).trim();
    }

    public enum Operator {
        EQUALS, NOT_EQUAL_TO,
        LESS_THAN, GREATER_THAN, LESS_OR_EQUAL, GREATER_OR_EQUAL,
        CONTAINS, DOES_NOT_CONTAIN,
        STARTS_WITH, ENDS_WITH
    }
}