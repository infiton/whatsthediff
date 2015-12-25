function ResultsPresenter(parent){
  var self = this;
  self.name = "results_presenter";
  self.parent = parent;

  self.has_file = function(type){
    return self.parent.result_files()[type];
  }

  self.path_to = function(type){
    return self.parent.get_url() + '/project_results/' + self.parent.result_files()[type];
  }
}