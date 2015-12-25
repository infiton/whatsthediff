function ResultsChecker(parent){
  var self = this;
  self.name = "results_checker"
  self.parent = parent;

  self.check_for_results = function(){
    $.ajax(self.parent.get_url(),{
      type: "GET",
      dataType: 'json',
      contentType: 'application/json',
      success: function(data){
        if(data && data.result_files && Object.keys(data.result_files).length > 0){
          parent.result_files(data.result_files);
          parent.state("completed");
        } else {
          setTimeout(self.check_for_results, self.parent.parameters.PING_RATE);
        }
      }
    })
  }

  $(document).ready(self.check_for_results);
}