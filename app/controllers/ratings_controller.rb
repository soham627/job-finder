class RatingsController < ApplicationController
  def index
    matching_ratings = Rating.where({ :user_id => @current_user.id})

    @list_of_ratings = matching_ratings.order({ :created_at => :desc })

    render({ :template => "ratings/index.html.erb" })
  end


   def show
    the_id = params.fetch("path_id")
    matching_organizations = Organization.where({ :id => the_id })
    @the_organization = matching_organizations.at(0)

    @allratings = Rating.where({ :org_id => @the_organization.id})
    agg_rating = 0
    num_reviews = 0
    @allratings.each do |a_rating|
      num_reviews = num_reviews+1
      agg_rating =agg_rating + a_rating.user_rating
    end 
    @final_rating = agg_rating/num_reviews.to_f
    @final_num_reviews = num_reviews
    render({ :template => "ratings/show.html.erb" })
  end

  def create
    the_rating = Rating.new
    the_rating.org_id = params.fetch("org")
    the_rating.user_rating = params.fetch("my_rating")
    the_rating.org_id = params.fetch("org")
    the_rating.user_id = @current_user.id

    if the_rating.valid?
      the_rating.save
      redirect_to("/organizations/#{the_rating.org_id}", { :notice => "Rating created successfully." })
    else
      redirect_to("/organizations/#{the_rating.org_id}", { :alert => "You've already reviewed this organization." })
    end
  end

   def create_from_org
    the_rating = Rating.new
    the_rating.org_id = params.fetch("org")
    the_rating.user_rating = params.fetch("my_rating")
    the_rating.explanation = params.fetch("query_explanation")
    the_rating.user_id = @current_user.id

    if the_rating.valid?
      the_rating.save
      redirect_to("/organizations/#{the_rating.org_id}", { :notice => "Rating created successfully." })
    else
      redirect_to("/organizations/#{the_rating.org_id}", { :alert => "You've already reviewed this organization." })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_rating = Rating.where({ :id => the_id }).at(0)

    the_rating.user_rating = params.fetch("new_selector")
    the_rating.explanation = params.fetch("new_explanation")
    the_rating.user_id = @current_user.id
    if the_rating.valid?
      the_rating.save
      redirect_to("/edit_review/#{the_rating.id}", { :notice => "Rating updated successfully."} )
    else
      redirect_to("/edit_review/#{the_rating.id}", { :alert => "Rating failed to update successfully." })
    end
  end

  def edit_page
    the_id = params.fetch("path_id")
    @the_rating = Rating.where({ :id => the_id }).at(0)

    @the_rating.user_id = @current_user.id
    render({ :template => "ratings/editpage.html.erb"})
  end 

  def destroy
    the_id = params.fetch("path_id")
    the_rating = Rating.where({ :id => the_id }).at(0)

    the_rating.destroy

    redirect_to("/ratings", { :notice => "Rating deleted successfully."} )
  end
end
