//these are global variables
//todo: refactor so that we don't use globals
var raw_csv_data = [];
var raw_csv_headers = [];

$(document).ready(function() {

	// The event listener for the file upload
	document.getElementById('txtFileUpload').addEventListener('change', upload, false);
	// Method that checks that the browser supports the HTML5 File API
    function browserSupportFileUpload() {
    	var isCompatible = false;
    	if (window.File && window.FileReader && window.FileList && window.Blob) {
       		isCompatible = true;
        }
        return isCompatible;
    }
    // Method that reads and processes the selected file
    function upload(evt) {
    	if (!browserSupportFileUpload()) {
        	alert('The File APIs are not fully supported in this browser!');
        } 
        else {
        	var data = null;
           	var file = evt.target.files[0];
            var reader = new FileReader();
            reader.readAsText(file);
            reader.onload = function(event) {
                var csvData = event.target.result;
                data = $.csv.toArrays(csvData);
                if (data && data.length > 0) {
                  display_and_prepare_form_upload(data);
                } 
                else {
                    alert('No data to import!');
                }
            };
            reader.onerror = function() {
                alert('Unable to read ' + file.fileName);
            };
    	}
    }
    function display_and_prepare_form_upload(data) {
    	if (data.length > 1){
    		$('#dvImportCsv').hide();
    		//tables for now: probably a better UI??
    		var table = $('<table></table>');
    		var table_head = $('<thead></thead>');
    		var table_head_row = $('<tr></tr>');
	
			//we are assuming here that the first column of the csv has headers
    		var headers = data.shift();

    		headers.forEach(function(header) {
    			var heading = $('<th></th>').text(header);
    			table_head_row.append(heading);
    		});
    		table_head.append(table_head_row);
    		table.append(table_head);
	
    		var table_body = $('<tbody></tbody>');
	
			var num_rows = data.length >= 3 ? 3 : data.length;
    		data.slice(0,num_rows + 1).forEach(function(row) {
    			var table_row = $('<tr></tr>');
    			row.forEach(function(value) {
    				var column = $('<td></td>').text(value);
    				table_row.append(column);
    			});
    			table_body.append(table_row);
    		});
	
    		table.append(table_body);
	
    		$('#CsvPreUploadDisplay').append(table);

    		var upload_form = $('#uploadCsvForm');
    		var uuid_selector = $('#uploadCsvForm #uuid');
            var field_selector = $('#uploadCsvForm #fieldsForUpload')
    		headers.forEach(function(header,index) {
    			var option = $('<option></option>').attr("value", index).text(header);
    			uuid_selector.append(option);
                field_selector.append('<input type="checkbox" value ="' + index + '" />' + header + '<br />');
    		});


    		//(uuid_selector.val());
            //make headers and data available at global scope for hashing and sending to server
            raw_csv_headers = headers;
            raw_csv_data = data;
    		$('#uploadCsv').show();
    	}
    	else {
    		alert('No data to import!');
    	}
    }

    
    $('#submitCsv').on('click', function(e) {
        e.preventDefault();

        var uuid = $('#uploadCsvForm #uuid').val();
        var fields = [];
        $('#uploadCsvForm #fieldsForUpload').children('input').each(function (){
            if($(this).is(':checked')) {
                fields.push(parseInt($(this).val()));
            }
        });

        var upload_headers = [raw_csv_headers[uuid]];

        fields.forEach(function(ind){
            upload_headers.push(raw_csv_headers[ind]);
        });

        var upload_data = [];

        raw_csv_data.forEach(function(row) {
            var upload_row = [row[uuid]];
            fields.forEach(function(ind){
                upload_row.push(md5(row[ind]));
            });
            upload_data.push(upload_row);
        });

        //console.log(raw_csv_headers);
        //console.log(raw_csv_data);
        $.ajax({
    		type: "POST",
    		url: $(this).attr('data-submit-url'),
    		data: {
                headers: upload_headers,
                data: upload_data
            },
    		cache: false,
    		dataType: "json",
    		//success: do a function!
    	})
    });
});