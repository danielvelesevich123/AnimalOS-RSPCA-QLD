public class aos_AddressService {
    public static final Map<String, List<String>> STATE_ABBRS_BY_CODES = new Map<String, List<String>>{
            //Australia
            'NSW' => new List<String>{
                    'newsouthwales', 'nsw'
            },
            'VIC' => new List<String>{
                    'victoria', 'vic'
            },
            'QLD' => new List<String>{
                    'queensland', 'qld'
            },
            'SA' => new List<String>{
                    'southaustralia', 'sa'
            },
            'WA' => new List<String>{
                    'westernaustralia', 'wa'
            },
            'TAS' => new List<String>{
                    'tasmania', 'tas'
            },
            'NT' => new List<String>{
                    'northernterritory', 'nt'
            },
            'ACT' => new List<String>{
                    'australiancapitalterritory', 'act'
            },
            'JB' => new List<String>{
                    'jervisbayterritory', 'jb'
            },
            //New Zealand
            'AUK' => new List<String>{
                    'auckland', 'auk'
            }
    };

    public static Map<String, List<String>> COUNTRY_ABBRS_BY_CODES = new Map<String, List<String>>{
            'AU' => new List<String>{
                    'australia', 'au', 'default'
            },
            'NZ' => new List<String>{
                    'newzealand', 'nz'
            }
    };

    public static String formatState(String state) {
        if (String.isNotBlank(state)) {
            state = state.toLowerCase().trim().deleteWhitespace();
            for (String key : STATE_ABBRS_BY_CODES.keySet()) {
                List<String> values = STATE_ABBRS_BY_CODES.get(key);
                for (String value : values) {
                    if (value.equalsIgnoreCase(state)) {
                        return key;
                    }
                }
            }
        }
        return state;
    }

    public static String formatCountry(String country) {
        if (String.isNotBlank(country)) {
            country = country.toLowerCase().trim().deleteWhitespace();
        }

        String defaultValue = '';
        for (String key : COUNTRY_ABBRS_BY_CODES.keySet()) {
            List<String> values = COUNTRY_ABBRS_BY_CODES.get(key);
            for (String value : values) {
                if (value.equalsIgnoreCase(country)) {
                    return key;
                }
                if (value.equalsIgnoreCase('default')) {
                    defaultValue = key;
                }
            }
        }
        return String.isBlank(country) ? defaultValue : country;
    }
}
