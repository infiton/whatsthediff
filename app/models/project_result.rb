require 'csv'
class ProjectResult < ActiveRecord::Base
  RESULT_TYPES = ["overlap","source_uniques", "target_uniques", "source_duplicates", "target_duplicates"]
  belongs_to :project

  validates :project, presence: true
  validates :result_type, inclusion: { :in => RESULT_TYPES }

  RESULT_TYPES.each do |result_type|
    scope result_type, -> { where(result_type: result_type) } 
  end

  def file_path
    ProjectResult.file_path(filename)
  end

  def file_exists?
    File.exists?(file_path)
  end

  class << self
    def create_overlap_for(project)
      source_user = project.try("source_user")
      return nil unless source_user

      target_user = project.try("target_user")
      return nil unless target_user

      filebase = "overlap_#{source_user.display_name}_#{target_user.display_name}"
      headers = [column_header(source_user), column_header(target_user)]

      filename = build_csv(project, filebase, headers) do
        compute_source_target_overlap(project)
      end

      create_result_for(project, result_type: "overlap", filename: filename)
    end

    def create_uniques_for(project, type)
      type = type.try(:to_s)
      return nil unless type

      user = project.try("#{type}_user")
      return nil unless user


      filebase = "uniques_for_#{user.display_name}"
      headers = [column_header(user)]

      filename = build_csv(project, filebase, headers) do
        send("compute_#{type}_uniques",project)
      end

      create_result_for(project, result_type: "#{type}_uniques", filename: filename)
    end

    def create_duplicates_for(project, type)
      type = type.try(:to_s)
      return nil unless type

      user = project.try("#{type}_user")
      return nil unless user

      filebase = "duplicates_for_#{user.display_name}"
      headers = [column_header(user), "Duplicate #{column_header(user)}"]

      duplicates = duplicates_for(project,type)

      return nil unless duplicates.any?

      filename = build_csv(project, filebase, headers) do
        duplicates.map {|pre_pair|
          pre_pair.first.split(',').combination(2).to_a
        }.flatten(1)
      end

      create_result_for(project, result_type: "#{type}_duplicates", filename: filename)
    end

    def file_path(filename)
      "#{APP_CONFIG[:results_path]}/#{filename}"
    end

    private

      def create_result_for(project, attrs={})
        pr = new(attrs)
        pr.project = project
        pr.save
      end

      def build_csv(project, filebase, headers)
        filename = "#{filebase}_#{project.slug}.csv".gsub!(/[^0-9A-Za-z.\-]/, '_')
        fp = file_path(filename)

        CSV.open(fp, 'w+') do |csv|
          csv << headers
          yield().each do |row|
            csv << row
          end
        end

        filename
      end

      def column_header(user)
        "Unique ID for #{user.display_name}"
      end

      def compute_source_target_overlap(project)
        sql = sanitize_sql_array(["""
          SELECT
            t1.uid, t2.uid
          FROM
            project_rows
          AS
            t1
          INNER JOIN
            project_rows
          AS
            t2
          ON (
            t1.digest = t2.digest AND
            t1.data_type = 'source' AND
            t2.data_type = 'target' AND
            t1.project_id = ? AND
            t2.project_id = ?
          );
        """, project.id, project.id])
        connection.execute(sql)
      end

      def compute_source_uniques(project)
        sql = uniques_sql(project,'source','target')
        connection.execute(sql)
      end

      def compute_target_uniques(project)
        sql = uniques_sql(project,'target','source')
        connection.execute(sql)
      end

      def uniques_sql(project,left,right)
        sanitize_sql_array(["""
          SELECT
            t1.uid
          FROM
            project_rows
          AS
            t1
          LEFT OUTER JOIN
            project_rows
          AS
            t2
          ON (
            t1.digest = t2.digest AND 
            t2.data_type = ? 
          )
          WHERE
            t1.data_type = ? AND
            t2.digest IS NULL AND
            t1.project_id = ?
          ;
        """, right,left, project.id])
      end

      def duplicates_for(project,type)
        sql = sanitize_sql_array(["""
          SELECT
            GROUP_CONCAT(uid)
          FROM
            project_rows
          WHERE
            project_id = ? AND
            data_type = ?
          GROUP BY
            digest
          HAVING
            COUNT(*) > 1
          ;
        """, project.id,type])
        connection.execute(sql)
      end
  end
end