function TargetUploader(parent) {
  var self = this;
  
  Uploader.apply(self,[parent,"target_uploader"]);

  //field matchers are modeled here as an array of
  //radio buttons
  self.matched_fields = ko.observableArray(
    ko.utils.arrayMap(parent.field_signature(), function(el){
      return ko.observable();
    })
  )

  self.field_for = function(idx){
    return self.matched_fields()[idx()];
  }

  self.field_idxs = function(){
    return self.matched_fields().map(function(e){return e();})
  }

  self.submit = function(){
    self.read_and_submit_data(
      self.file(),
      "target",
      self.unique_id_idx(),
      self.field_idxs(),
      function(d){
        if(d && d.uploaded_rows){
          parent.target_rows_uploaded( parent.target_rows_uploaded() + d.uploaded_rows);
        }
      },
      function(d){
        if(d && d.uploaded_rows){
          parent.target_rows_uploaded( parent.target_rows_uploaded() + d.uploaded_rows);
        }
        parent.state("target_uploaded");
      }
    );
  }
}