function SourceUploader(parent){
  var self = this;

  Uploader.apply(self,[parent,"source_uploader"]);

  self.diff_fields = ko.observableArray();

  self.readSourceHeader = function(){
    self.diff_fields([]);
    self.readHeader();
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
        if (data && data.field_signature){
          parent.field_signature(data.field_signature);
        }
        self.read_and_submit_data(
          self.file(), 
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