class ProjectDiffer
  def initialize(project)
    @project = project
  end

  def call
    @source_target_overlap = compute_source_target_overlap

    @source_uniques = compute_source_uniques
    @target_uniques = compute_target_uniques

    @source_duplicates = compute_source_duplicates
    @target_duplicates = compute_target_duplicates
    binding.pry
  end

  private

    def connection
      @connection ||= ActiveRecord::Base.connection
    end

    def compute_source_target_overlap
      sql = ActiveRecord::Base.send(:sanitize_sql_array,["""
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
      """, @project.id, @project.id])
      connection.execute(sql).to_a
    end

    def uniques_sql(left,right)
      ActiveRecord::Base.send(:sanitize_sql_array,["""
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
      """, right,left, @project.id])
    end

    def compute_source_uniques
      sql = uniques_sql('source','target')
      connection.execute(sql).to_a
    end

    def compute_target_uniques
      sql = uniques_sql('target','source')
      connection.execute(sql).to_a
    end

    def duplicates_sql(type)
      ActiveRecord::Base.send(:sanitize_sql_array,["""
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
      """, @project.id,type])
    end

    def compute_source_duplicates
      pair_duplicates('source')
    end

    def compute_target_duplicates
      pair_duplicates('target')
    end

    def pair_duplicates(type)
      sql = duplicates_sql(type)
      binding.pry
      connection.execute(sql).map{|pre_pair|
        pre_pair.first.split(',').combination(2).to_a
      }.flatten(1)
    end

end