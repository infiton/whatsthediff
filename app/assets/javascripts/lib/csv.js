Csv = function(){
  if( !(this instanceof Csv) ){
    return new Csv();
  }

  var internals = this._internals = {};
  var self = this;

  internals.rows = [];
};

Csv.prototype.set_header = function(row){
  var internals = this._internals;

  if( row instanceof CsvRow && row.is_valid() ){
    internals.header = row;
    return row;
  } else {
    return null;
  }
};

Csv.prototype.header = function(){
  var internals = this._internals;

  if( internals.header ){
    return internals.header;
  } else {
    return null;
  }
}

Csv.prototype.rows = function(){
  var internals = this._internals;
  return internals.rows;
}

Csv.prototype.push = function(row){
  var internals = this._internals;

  if( row instanceof CsvRow && row.is_valid() ){
    internals.rows.push(row);
    return row;
  } else {
    return null;
  }
}

Csv.prototype.length = function(){
  var internals = this._internals;

  return internals.rows.length;
}

CsvRow = function(line){
  if( !(this instanceof CsvRow) ){
    return new CsvRow(line);
  }

  var internals = this._internals = {}
  var self = this;

  internals.raw_text = line;
  
  if( typeof line === 'string' ){
    internals.values = line.split(',');
    internals.valid = true;
  } else {
    internals.valid = false;
    internals.error = "Must pass a string to CsvRow constuctor";
  }

};

CsvRow.prototype.is_valid = function(){
  var internals = this._internals;

  return !!internals.valid;
}

CsvRow.prototype.row = function(){
  var self = this
  var internals = this._internals;

  if( self.is_valid() ) {
    return internals.values;
  } else {
    return [];
  }
}