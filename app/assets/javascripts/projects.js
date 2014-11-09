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
                  process_and_send_data(data);
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