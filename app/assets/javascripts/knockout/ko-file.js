ko.bindingHandlers.file = {
  init: function(element, valueAccessor, allBindingsAccessor){
    var $element = $(element);
    var value = valueAccessor();

    $element.change(function() {
      var file = this.files[0];
      if(ko.isObservable(value)) {
        value(file);
      }
    });
  }
}