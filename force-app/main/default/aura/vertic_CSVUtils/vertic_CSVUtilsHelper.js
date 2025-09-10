({
    ROW_SEPARATOR: '\r\n',
    COL_SEPARATOR: ',',

    OBJECT2CSV: function (objArray, noHeaders) {
        let array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
        let csv = '';

        var helper = this;

        if (noHeaders !== true) {
            let row = [];
            for (var index in array[0]) {
                row.push(helper.encodeCSVCell(index, helper.COL_SEPARATOR));
            }
            csv += row.join(helper.COL_SEPARATOR) + helper.ROW_SEPARATOR;
        }

        for (let i = 0; i < array.length; i++) {
            let row = [];
            for (let index in array[i]) {
                row.push(helper.encodeCSVCell(array[i][index], helper.COL_SEPARATOR));
            }
            csv += row.join(helper.COL_SEPARATOR) + helper.ROW_SEPARATOR;
        }
        return csv;
    },

    ARRAY2CSV: function (arr) {

        var helper = this;

        var rows = [];
        arr.forEach(function (rowData) {
            var cols = [];
            rowData.forEach(function (cell) {
                var val = helper.encodeCSVCell(cell, helper.COL_SEPARATOR);
                cols.push(val);
            });
            var rowStr = cols.join(helper.COL_SEPARATOR);
            rows.push(rowStr);
        });
        return rows.join(helper.ROW_SEPARATOR);
    },

    encodeCSVCell: function (val, colSeparator) {

        var regExp = new RegExp('"', "g"),

        val = val || '';
        val = '' + val;

        // Replace " -> ""
        val = val.replace(regExp, '""')

        let hasSeparator = val.indexOf(colSeparator) !== -1;
        if(hasSeparator){
            val = '"' + val + '"';
        }

        return val;
    },

    processorToCSV: function (cmp, processor, requests) {

        var helper = this;

        return new Promise($A.getCallback(function (resolve, reject) {

            var promises = [];
            requests.forEach(function (request) {
                var promise = cmp.utils.execute(
                    cmp,
                    processor,
                    request
                );
                promises.push(promise);
            });

            Promise.all(promises).then(function (results) {

                var headers;
                var rows = [];
                results.forEach(function (result) {
                    if(headers === undefined){
                        headers = result.dto.CSV.headers;
                    }
                    rows = rows.concat(result.dto.CSV.rows);
                });

                if(headers){
                    rows.unshift(headers);
                }

                var csv = helper.ARRAY2CSV(rows);

                resolve(csv);

            }).catch(reject);

        }));

    },

    downloadCSV: function (csv, fileName) {
        var csvData = new Blob([csv], { type: 'text/plain' });
        var csvUrl = URL.createObjectURL(csvData);
        var a = document.createElement("a");
        a.href =  csvUrl;
        a.download = fileName || "data.csv";

        var isFirefox = navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
        if(isFirefox){
            a.dispatchEvent(new MouseEvent('click', {bubbles: true, cancelable: true}));
        } else{
            a.click();
        }
    }
})