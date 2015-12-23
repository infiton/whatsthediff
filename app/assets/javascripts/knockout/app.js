function App(project_id, state){
  var self = this;
  self.project_id = project_id;

  /*
    App parameter declarations
    **************************
  */
  self.parameters = {}
  self.parameters.HEADER_SIZE = 5
  self.parameters.CHUNK_SIZE = 100;
  /*
    **************************
  */

  self.state = ko.observable(state);
  
  self.state_app = ko.computed(function(){
    var app;
    switch(self.state()){
      case 'new':
        app = new SourceUploader(self);
        break;
      case 'source_uploaded':
        app = new TargetSelector(self);
        break;
      case 'target_selected':
        app = new TargetUploader(self);
        break;
      default:
        app = new SourceUploader(self);
        break;
    }

    return app;
  });

  
  self.readHeader = function(file,target) {
    var header_reader = new LineReader();
    var header_csv = new Csv();

    header_reader.on('line', function(line,next){

      if(!header_csv.header()){
        header_csv.set_header(new CsvRow(line));
        next();
      } else {
        header_csv.push(new CsvRow(line));
        if(header_csv.length() >= self.parameters.HEADER_SIZE){
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

  self.read_and_submit_data = function(file, data_type, unique_id_idx, field_idxs, on_end){
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
        
        if( hash_buffer.length >= self.parameters.CHUNK_SIZE){
          self.send_data_chunk(data_type, hash_buffer, false, function(){
            hash_buffer.length = 0;
            next();
          })
        } else {
          next();
        }
      }
    });

    lr.on('end', function(){
      self.send_data_chunk(data_type, hash_buffer, true, function(){
        //we are done uploading to the server
        //move project to source_uploaded state
        hash_buffer.length = 0;
        on_end();
      })
    })

    lr.read(file);
  };

  self.send_data_chunk = function(data_type, hash_buffer, is_last_chunk, on_success) {
    $.ajax(self.patch_url(), {
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
        on_success();
      },
      error: function(data){
        console.log(data);
      }
    });
  };

  self.patch_url = function(){
    return parent.patch_url;
  }

  self.hasFileApi = function() {
    return window.File && window.FileReader && window.Blob
  }

}