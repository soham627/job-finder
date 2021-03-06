class JobsController < ApplicationController
  skip_before_action(:force_user_sign_in, { :only => [:home, :index]})
  def home 
    render({ :template => "jobs/home.html.erb" })
  end 
  
  def index
    #matching_jobs = Job.all
    @q = Job.ransack(params[:q])
    @list_of_jobs = @q.result(:distinct => true).includes(:industry, :org)


    #@list_of_jobs = Job.all.order({ :created_at => :desc })
    
    render({ :template => "jobs/index.html.erb" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_jobs = Job.where({ :id => the_id })

    @the_job = matching_jobs.at(0)

    render({ :template => "jobs/show.html.erb" })
  end

  def job_form 
    render({ :template => "jobs/creator.html.erb" })
  end 
  def create
    the_job = Job.new
    the_job.link = params.fetch("query_link")
    the_job.description = params.fetch("query_description")
    the_job.int_students = params.fetch("query_int_students", false)
    the_job.deadline = params.fetch("query_deadline")
    the_job.industry_id = params.fetch("query_industry_id")
    the_job.role = params.fetch("query_role")
    the_job.poster_id = @current_user.id
    #the_job.id = Job.all.at(-1).id + 1
    #the_job.created_at = Time.now 
    #the_job.updated_at = Time.now 

    orgname = params.fetch("prepop_org")
    if orgname == 'blank' || orgname == 'none'
      new_orga = Organization.new 
      new_orga.name = params.fetch("new_org_name")
      new_orga.website = params.fetch("new_org_website")
      if new_orga.valid?
        new_orga.save
      else
        redirect_to("/jobs/index", { :alert => "Organization is invalid." })
      end
      the_job.org_id = new_orga.id
    else  
      the_org_name = params.fetch("prepop_org")
      the_org = Organization.where({ :name => the_org_name}).at(0)
      the_job.org_id = the_org.id
    end 
    if the_job.valid?
      the_job.save
      redirect_to("/jobs", { :notice => "Job created successfully." })
    else
      redirect_to("/jobs", { :alert => "Job failed to create "})
    end
  end


  def update
    the_id = params.fetch("path_id")
    the_job = Job.where({ :id => the_id }).at(0)

    the_job.link = params.fetch("query_link")
    the_job.description = params.fetch("query_description")
    the_job.int_students = params.fetch("query_int_students", false)
    the_job.deadline = params.fetch("query_deadline")
    the_job.industry_id = params.fetch("query_industry_id")
    org_name = params.fetch("query_org_name")
    if Organization.where({ :name => org_name}).at(0)!= nil
      the_job.org_id = Organization.where({ :name => org_name}).at(0).id
    else
      the_organization = Organization.new
      the_organization.website = params.fetch("query_website")
      the_organization.name = params.fetch("query_name")

      if the_organization.valid?
        the_organization.save
      else
        redirect_to("/jobs/#{the_job.id}", { :alert => "Job failed to update successfully (invalid organization)." })
      end
    end 
    the_job.role = params.fetch("query_role")

    if the_job.valid?
      the_job.save
      redirect_to("/jobs/#{the_job.id}", { :notice => "Job updated successfully."} )
    else
      redirect_to("/jobs/#{the_job.id}", { :alert => "Job failed to update successfully." })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_job = Job.where({ :id => the_id }).at(0)

    the_job.destroy

    redirect_to("/jobs", { :notice => "Job deleted successfully."} )
  end
end
