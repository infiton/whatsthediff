function App(project_id){
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

  self.source_file = ko.observable();
  self.source_header = ko.observable();
  self.unique_id_idx = ko.observable();
  self.diff_fields = ko.observableArray();

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

  self.readSourceHeader = function(){
    self.source_header(null);
    self.unique_id_idx(null);
    self.diff_fields([]);
    self.readHeader(self.source_file(), self.source_header);
  };

  self.clear_diff_fields = function(idx){
    self.diff_fields.remove(function(item){
      return item[0] === idx;
    })
  };

  self.sorted_diff_fields = function(){
    return self.diff_fields()
      .sort(function(x,y){
        return x[0] - y[0];
      });
  };

  self.field_idxs = function(){
    return self
    .sorted_diff_fields()
    .map(function(el){
      return el[0];
    })
  }

  self.field_signature = function(){
    return self
      .sorted_diff_fields()
      .map(function(el){
      return el[1];
    });
  };

  self.submit = function(){
    var payload = {
      file_type: 'source', //should be either 'source' or 'target'
      field_signature: self.field_signature()
    }
    $.ajax('/projects/' + self.project_id, {
      type: "PATCH",
      data_type: "json",
      data: {
        op: "configure", 
        args: {
          field_signature: self.field_signature()
        }
      },
      success: function(data){
        self.read_and_submit_data(self.source_file(), "source");
      },
      error: function(data){
        console.log(data);
      }
    })
  };

  self.send_data_chunk = function(data_type, hash_buffer, on_success) {
    $.ajax('/projects/' + self.project_id, {
      type: "PATCH",
      dataType: "json",
      data: {
        op: "load_data_chunk",
        args: {
          data_type: data_type,
          chunk: hash_buffer
        }
      },
      success: function(data){
        on_success();
      },
      error: function(data){
        console.log(data);
      }
    });
  };

  self.read_and_submit_data = function(file, data_type){
    var lr = new LineReader();
    var line_count = -1;

    var field_idxs = self.field_idxs();
    var unique_id_idx = self.unique_id_idx();
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
        var hobj = {};
        hobj[uid] = md5(hkey);

        hash_buffer.push(hobj);
        
        if( hash_buffer.length >= self.parameters.CHUNK_SIZE){
          self.send_data_chunk(data_type, hash_buffer, function(){
            hash_buffer.length = 0;
            next();
          })
        } else {
          next();
        }
      }
    });

    lr.on('end', function(){
      self.send_data_chunk(hash_buffer, function(){
        hash_buffer.length = 0;
        console.log("All the data got sent!!");
      })
    })

    lr.read(file);
  };

  self.hasFileApi = function() {
    return window.File && window.FileReader && window.Blob
  }
}