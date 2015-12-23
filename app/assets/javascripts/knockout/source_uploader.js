function SourceUploader(parent){
  var self = this;
  self.name = "source_uploader";
  self.parent = parent;

  self.source_file = ko.observable();
  self.source_header = ko.observable();
  self.unique_id_idx = ko.observable();
  self.diff_fields = ko.observableArray();

  self.source_uploaded = ko.observable();
  self.uploaded_lines = ko.observable();

  self.target_email = ko.observable();

  self.showRowsUploaded = ko.observable(false);

  self.readSourceHeader = function(){
    self.source_header(null);
    self.unique_id_idx(null);
    self.diff_fields([]);
    parent.readHeader(self.source_file(), self.source_header);
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
    self.showRowsUploaded(true);

    $.ajax(parent.patch_url(), {
      type: "PATCH",
      data_type: "json",
      contentType: "application/json",
      data: JSON.stringify({
        op: "configure", 
        args: {
          field_signature: self.field_signature()
        }
      }),
      success: function(data){
        parent.read_and_submit_data(
          self.source_file(), 
          "source",
          self.unique_id_idx(),
          self.field_idxs(),
          function(d){
            if(d && d.uploaded_rows){
              parent.source_rows_uploaded( parent.source_rows_uploaded() + d.uploaded_rows);
            }
          },
          function(d){
            if(d && d.uploaded_rows){
              parent.source_rows_uploaded( parent.source_rows_uploaded() + d.uploaded_rows);
            }
            parent.state("source_uploaded");
          }
        );
      },
      error: function(data){
        console.log(data);
      }
    })
  }; 
}