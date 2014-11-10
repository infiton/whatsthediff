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
                  display_and_prepare_for_upload(data);
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
    function display_and_prepare_for_upload(data) {
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
    		headers.forEach(function(header) {
    			var option = $('<option></option>').attr("value", header).text(header);
    			uuid_selector.append(option);
    		});

    		//(uuid_selector.val());
    		$('#uploadCsv').show();
    	}
    	else {
    		alert('No data to import!');
    	}
    }

    $('#uploadCsvForm')
    	.bind("ajax:beforeSend", function(evt, xhr, settings) {
    		alert($('#uploadCsvForm #uuid').val());
    	});

    function process_and_send_data(data) {
    	$.ajax({
    		type: "POST",
    		url: $('#upload').data('url'),
    		data: {csvData: data},
    		cache: false,
    		dataType: "json",
    		//success: do a function!
    	})
    }
});