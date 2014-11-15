class ProjectsController < ApplicationController
  def new

  end

  def create

    @user = User.where(email: params[:user][:email]).first
    @user = @user ? @user.collect_from(user_params) : create_user

    if @user.save == false
      flash[:notice] = @user.errors.full_messages.to_sentence
      redirect_to :back and return
    end

    @project = @user.projects.build()

    if @user.save && @project.save
      flash[:notice] = "Project Successfully Created"
      redirect_to project_url(@project)
    else
      flash[:notice] = @project.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  def show
    @project = Project.find(params[:id])

    @user = @project.user
    #this will not exist until the state is brought here
    #will be nil unless state >= target_user_added
    @target_user = @project.target_user

    if @project.project_data and @project.project_data.has_attribute?(:source_list)
      @project_headers = @project.project_data.source_list.first.keys.select{|k| k!="uuid"}
    end

    #this is faster than loading project_data and sending it to the view
    if @project.completed?
      @project_counts = @project.project_data.project_counts
    end
  end

  def upload_source_data
    @project = Project.find(params[:id])

    if @project.upload_source! :source_uploaded, params[:data]
      flash[:notice] = "The Source Data has been uploaded"
    else
      flash[:notice] = "There was an error uploading the data"
    end

    respond_to do |format|
      format.json { render :json => {:reload => project_url(@project) } }
    end
  end

  def add_target_user
    @project = Project.find(params[:id])
    @target_user = User.where(email: params[:project][:user][:email]).first
    @target_user ||= create_user

    if @target_user.save
      @project.add_target_user! :target_user_added, @target_user
      flash[:notice] = "An Email request has been sent to #{@target_user.email}"
      redirect_to project_url(@project)
    else
      flash[:notice] = @target_user.errors.full_messages.to_sentence
      redirect_to :back and return
    end
  end

  def upload_target_data
    @project = Project.find(params[:id])

    if @project.upload_target! :data_uploaded, params[:data]
      flash[:notice] = "The Target Data has been uploaded"
    else
      flash[:notice] = "There was error uploading the data"
    end

    respond_to do |format|
      format.json { render :json => {:reload => project_url(@project) } }
    end
  end

  def calculate_difference
    @project = Project.find(params[:id])
    @project_data = @project.project_data

    source_hash, source_dupes = build_hash_check_dupes @project_data.source_list
    target_hash, target_dupes = build_hash_check_dupes @project_data.target_list

    source_values = source_hash.keys
    target_values = target_hash.keys

    source_uniq = source_values - target_values
    target_uniq = target_values - source_values

    source_target_union = source_values & target_values

    @project_data.source_dupes = source_dupes
    @project_data.target_dupes = target_dupes

    @project_data.source_uniq = source_uniq.map{|k| source_hash[k]}
    @project_data.target_uniq = target_uniq.map{|k| target_hash[k]}
    @project_data.source_target_union = source_target_union.map{|k| [source_hash[k],target_hash[k]]}

    if @project_data.save
      @project.complete!
      @project_counts = @project_data.project_counts
      render :partial => "project_results"
    else
      render :partial => "error_processing_results"
    end
  end

  def download
    @project = Project.find(params[:id])

    respond_to do |format|
      format.csv { send_data @project.project_data.to_csv(params[:list]) }
      format.xls { send_data @project.project_data.to_csv(params[:list],col_sep: "\t") }
    end
  end

protected

  def create_user
    @user = User.new(user_params)
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :company)
  end

  private

    def build_hash_check_dupes arr
      hsh = {}
      dps = []

      arr.each do |row|
        uuid = row["uuid"]
        #concat all hashed fields together into large hash
        #make sure they are sorted by field name
        bh = row.to_h.except("uuid").sort.map{|x| x[1]}.join('')
        if hsh.has_key? bh
          dps << [hsh[bh], uuid]
        else
          hsh[bh] = uuid
        end  
      end
    return hsh, dps  
  end
end
