Rails.logger.warn "WARNING: 'results_path' is not set in application.yml, setting to #{Rails.root}/tmp/files" unless APP_CONFIG[:results_path]
results_path = APP_CONFIG[:results_path] || "#{Rails.root}/tmp/files"

begin
  FileUtils.mkdir_p(results_path) unless File.directory?(results_path)
ensure
  File.directory?(results_path)
end


APP_CONFIG[:results_path] = results_path