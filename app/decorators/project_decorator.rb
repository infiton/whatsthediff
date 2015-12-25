class ProjectDecorator < Draper::Decorator
  delegate_all

  def templates
    self.class.templates
  end

  def to_hash
    {
      project_id: to_param,
      state: state,
      field_signature: humanized_fields,
      source_rows_uploaded: source_rows_size,
      targets_row_uploaded: target_rows_size,
      result_files: result_files
    }
  end

  def knockout
    to_hash.to_json.html_safe
  end

  def self.templates
    ["source_uploader", "target_selector", "target_uploader", "results_checker", "results_presenter"]
  end
end