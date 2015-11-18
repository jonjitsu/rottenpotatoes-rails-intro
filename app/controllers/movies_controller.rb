class MoviesController < ApplicationController
  helper_method :sort_column, :sort_direction

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    @movies = Movie.all
    if params[:ratings]
      ratings = params[:ratings].keys
      #@movies = @movies.where({ rating: ratings}) if ! ratings.none?
      @movies.where!({ rating: ratings}) if ! ratings.none?
    end
    if params[:sort]
      @movies.order!(sort_column + " " + sort_direction)
    end
#    @all_ratings = @movies.map { |m| m.rating }.uniq
#    @all_ratings = Movie.only_fields(@movies, :rating)
    @all_ratings = to_hash_with_checks(Movie.all_ratings)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end


  private

  def to_hash_with_checks ratings
    param_ratings = params[:ratings].nil? ? ratings : params[:ratings].keys

    ratings.map do |rating_name|
      { :name    => rating_name,  :checked => param_ratings.include?(rating_name)  }
    end
  end

  def sort_column
    Movie.column_names.include?(params[:sort]) ? params[:sort] : nil
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : nil
  end

end
