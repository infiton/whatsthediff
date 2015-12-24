function Uploader(parent,name){
  var self = this;
  self.parent = parent;
  self.name = name;

  self.file = ko.observable();
  self.header = ko.observable();
  self.unique_id_idx = ko.observable();

  self.uploaded = ko.observable();
  self.uploaded_lines = ko.observable();

  self.showRowsUploaded = ko.observable(false);

  self.readHeader = function(){
    self.header(null);
    self.unique_id_idx(null);
    self._readHeader(self.file(), self.header);
  }

  self._readHeader = function(file,target) {
    var header_reader = new LineReader();
    var header_csv = new Csv();

    header_reader.on('line', function(line,next){

      if(!header_csv.header()){
        header_csv.set_header(new CsvRow(line));
        next();
      } else {
        header_csv.push(new CsvRow(line));
        if(header_csv.length() >= parent.parameters.HEADER_SIZE){
          this._emit('end');
        } else {
          next();
        }
      }
    });

    header_reader.on('error', function(err){
      console.log(err);
    });

    header_reader.on('end',function(){
      target(header_csv);
    });

    header_reader.read(file);
  }

  self.read_and_submit_data = function(file, data_type, unique_id_idx, field_idxs, on_next, on_end){
    var lr = new LineReader();
    var line_count = -1;
  
    var hash_buffer = [];

    lr.on('line', function(line,next){
      line_count++;
      if( line_count == 0){
        //skip the header line
        next()
      } else {
        var row = new CsvRow(line);

        var hkey = '';

        for(var i = 0; i < field_idxs.length; i++) {
          var idx = field_idxs[i];
          hkey += row.row()[idx];
        }
        var uid = row.row()[unique_id_idx];
        var hobj = {
          uid: uid,
          digest: md5(hkey)
        };

        hash_buffer.push(hobj);
        
        if( hash_buffer.length >= parent.parameters.CHUNK_SIZE){
          self.send_data_chunk(data_type, hash_buffer, false, function(data){
            on_next(data);
            hash_buffer.length = 0;
            next();
          })
        } else {
          next();
        }
      }
    });

    lr.on('end', function(){
      self.send_data_chunk(data_type, hash_buffer, true, function(data){
        //we are done uploading to the server
        //move project to source_uploaded state
        hash_buffer.length = 0;
        on_end(data);
      })
    })

    lr.read(file);
  };

  self.send_data_chunk = function(data_type, hash_buffer, is_last_chunk, on_success) {
    $.ajax(parent.patch_url(), {
      type: "PATCH",
      dataType: "json",
      contentType: "application/json",
      data: JSON.stringify({
        op: "load_data_chunk",
        args: {
          data_type: data_type,
          is_last_chunk: is_last_chunk,
          chunk: hash_buffer
        }
      }),
      success: function(data){
        on_success(data);
      },
      error: function(data){
        console.log(data);
      }
    });
  };
}