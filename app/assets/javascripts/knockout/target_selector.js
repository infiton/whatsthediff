function TargetSelector(parent){
  var self = this;
  self.name = "target_selector";
  self.parent = parent;

  self.target_email = ko.observable();

  self.submit = function(){
    $.ajax(parent.patch_url(), {
      type: "PATCH",
      dataType: "json",
      contentType: "application/json",
      data: JSON.stringify({
        op: "select_target",
        args: {
          target_email: self.target_email()
        }
      }),
      success: function(data){
        parent.state("target_selected");
      },
      error: function(data){
        console.log(data);
      }
    })
  }
}