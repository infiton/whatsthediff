    //these are global variables
//todo: refactor so that we don't use globals
var raw_csv_data = [];
var raw_csv_headers = [];

$(document).ready(function() {

    //This javascript needs to be refactored
    //I have not made it DRY... getting it work first.. then we write tests.. then refactor
    //I think this may be a good opportunity to use something like AngularJS

   $('#sourceFileUpload').change(function(e){upload('source', e)});
   $('#targetFileUpload').change(function(e){upload('target', e)});

	// Method that checks that the browser supports the HTML5 File API
    function browserSupportFileUpload() {
    	var isCompatible = false;
    	if (window.File && window.FileReader && window.FileList && window.Blob) {
       		isCompatible = true;
        }
        return isCompatible;
    }

    function upload(list_type,evt) {
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
                  display_and_prepare_form_upload(data,list_type);
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

    function display_and_prepare_form_upload(data,list_type) {
    	if (data.length > 1){
    		$('#'+list_type+'ImportCsv').hide();
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

    		var upload_form = $('#'+list_type+'UploadCsvForm');


            if (list_type == 'source') {
              var uuid_selector = $('#'+list_type+'UploadCsvForm #uuid');
              var field_selector = $('#'+list_type+'UploadCsvForm #fieldsForUpload')
    		  headers.forEach(function(header,index) {
    			var option = $('<option></option>').attr("value", index).text(header);
    			uuid_selector.append(option);
                field_selector.append('<input type="checkbox" value ="' + index + '" />' + header + '<br />');
    		  });
            }

            if (list_type == "target") {
                $('.header_select').each(function(i,select) {
                    headers.forEach(function(header,index) {
                        var option = $('<option></option>').attr("value", index).text(header);
                        $(select).append(option);
                    });
                });
            }


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


    $('#submitSourceCsv').on('click', function(e) {
        e.preventDefault();

        var uuid = $('#sourceUploadCsvForm #uuid').val();
        var fields = [];
        $('#sourceUploadCsvForm #fieldsForUpload').children('input').each(function (){
            if($(this).is(':checked')) {
                fields.push(parseInt($(this).val()));
            }
        });

        var upload_data = [];

        raw_csv_data.forEach(function(row) {
            var upload_row = {"uuid": row[uuid]};
            fields.forEach(function(ind){
                upload_row[raw_csv_headers[ind]] = md5(row[ind]);
            });
            upload_data.push(upload_row);
        });

        ajax_submit($(this).attr('data-submit-url'), upload_data);
    });

    $('#submitTargetCsv').on('click', function(e) {
        e.preventDefault();

        header_indexes = {}

        $('.header_select').each(function(i,select){
            header_indexes[$(select).attr("name")] = $(select).val();
        });

        upload_data = [];

        raw_csv_data.forEach(function(row) {
            var upload_row = {}
            Object.keys(header_indexes).forEach(function(key) {
                if(key == "uuid"){
                    upload_row[key] = row[header_indexes[key]];
                }
                else {
                    upload_row[key] = md5(row[header_indexes[key]]);
                }
            });
            upload_data.push(upload_row);
        })

        ajax_submit($(this).attr('data-submit-url'), upload_data)
    });

    function ajax_submit(url,data){
        $.ajax({
    		type: "POST",
    		url: url,
    		data: {data: data},
    		cache: false,
    		dataType: "JSON",
    		success: function(result) {
                window.location = result.reload
            }
    	});
    }

    $("div[data-load]").filter(":visible").each(function(){
        $('#calculating-message').append("<p>Hey we're thinkin'....</p>");
        var path = $(this).attr('data-load');
        $(this).load(path);
        $('#calculating-message').hide();
    })
});