class ProjectDecorator < Draper::Decorator
  delegate_all

  def templates
    self.class.templates
  end

  def knockout
    {
      project_id: to_param,
      state: state,
      field_signature: field_signature,
      source_rows_uploaded: source_rows_size
    }.to_json.html_safe
  end

  def self.templates
    ["source_uploader", "target_selector", "target_uploader"]
  end
end