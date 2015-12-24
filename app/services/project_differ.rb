class ProjectDiffer
  def initialize(project)
    @project = project
  end

  def call
    binding.pry
  end
end






#The queries

#source and target overlap:
#SELECT t1.uid, t2.uid FROM project_rows AS t1 INNER JOIN project_rows AS t2 ON (t1.digest = t2.digest AND t1.data_type="source" AND t2.data_type="target");

#source uniques
#SELECT t1.uid FROM project_rows AS t1 LEFT OUTER JOIN project_rows AS t2 ON (t1.digest = t2.digest AND t2.data_type = "target") WHERE t1.data_type = "source" AND t2.digest is null;

#target uniques
#SELECT t1.uid FROM project_rows AS t1 LEFT OUTER JOIN project_rows AS t2 ON (t1.digest = t2.digest AND t2.data_type = "source") WHERE t1.data_type = "target" AND t2.digest is null;

#source duplicates
#SELECT GROUP_CONCAT(uid) FROM project_rows WHERE data_type="target" GROUP BY digest HAVING COUNT(*) >= 2;

#target_duplicates
#SELECT GROUP_CONCAT(uid) FROM project_rows WHERE data_type="target" GROUP BY digest HAVING COUNT(*) >= 2;