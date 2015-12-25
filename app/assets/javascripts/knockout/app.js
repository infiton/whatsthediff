function App(attrs){
  var self = this;
  self.project_id = attrs.project_id;

  /*
    App parameter declarations
    **************************
  */
  self.parameters = {};
  self.parameters.HEADER_SIZE = 5;
  self.parameters.CHUNK_SIZE = 100;
  self.parameters.PING_RATE = 5000;
  /*
    **************************
  */

  self.state = ko.observable(attrs.state || "new");
  self.source_rows_uploaded = ko.observable(attrs.source_rows_uploaded || 0);
  self.target_rows_uploaded = ko.observable(attrs.target_rows_uploaded || 0);
  self.field_signature = ko.observable(attrs.field_signature || []);
  self.result_files = ko.observable(attrs.result_files || []);
  
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
      case 'target_uploaded':
        app = new ResultsChecker(self);
        break;
      case 'completed':
        app = new ResultsPresenter(self);
        break;
      default:
        app = new SourceUploader(self);
        break;
    }

    return app;
  });
  
  self.patch_url = function(){
    return "/projects/" + self.project_id;
  }

  self.get_url = function(){
    return self.patch_url();
  }

  self.hasFileApi = function() {
    return window.File && window.FileReader && window.Blob
  }

}