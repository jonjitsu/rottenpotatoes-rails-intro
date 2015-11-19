class MoviesController < ApplicationController
  helper_method :sort_column, :sort_direction, :filters

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  # @TODO preserve flash between any redirects
  # @DONE sorting and filtering work well together
  # @DONE add session
  # @DONE session doesn't override params
  # @DONE all unchecked than use session
  # @DONE preserve restfulness (update url with a redirect when the session contains other information)
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def deep_diff(h1, h2)
    (h1.keys + h2.keys).uniq.inject({}) do |memo, key|
      left = h1[key]
      right = h2[key]
      
      next memo if left == right
      
      if left.class==Hash && right.class==Hash
        memo[key] = deep_diff(left, right)
      else
        memo[key] = [left, right]
      end
      
      memo
    end
  end

  def environment
    return @env if @env
    env = session[:env] ? session[:env] : {}
    env.symbolize_keys!

    if params[:sort] && params[:direction]
      env[:sort] = params[:sort]
      env[:direction] = params[:direction]
    end
    if params[:ratings]
      env[:ratings] = params[:ratings]
    else
#      session.delete(:ratings)
    end
    session[:env] = env.deep_dup

    diff = deep_diff(env, params.extract!(:ratings, :sort, :direction).symbolize_keys)
    if ! diff.empty?
      redirect_with_flash env 
    end

    @env = env 
  end

  def redirect_with_flash env 
    # fix flash
    if flash.empty?
      redirect_to movies_path(env)
    else
      redirect_to movies_path(env), :flash => flash.to_hash
    end
  end
 
  def index
    session.delete(:blah)
    env = environment

    @movies = Movie.all
    if env[:ratings]
      ratings = env[:ratings].keys
      #@movies = @movies.where({ rating: ratings}) if ! ratings.none?
      @movies.where!({ rating: ratings}) if ! ratings.none?
    end
    @sort = {}
    if env[:sort]
      @sort[:column] = sort_column
      @sort[:direction] = sort_direction
      @movies.order!(@sort[:column] + " " + @sort[:direction])
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
    env = environment
    param_ratings = env[:ratings].nil? ? ratings : env[:ratings].keys

    ratings.map do |rating_name|
      { :name    => rating_name,  :checked => param_ratings.include?(rating_name)  }
    end
  end

  def sort_column
    env = environment
    Movie.column_names.include?(env[:sort]) ? env[:sort] : nil
  end
  
  def sort_direction
    env = environment
    %w[asc desc].include?(env[:direction]) ? env[:direction] : nil
  end

  def filters
    env = environment
    env[:ratings].nil? ? {} : { :ratings => env[:ratings] }
  end
  
  # Hash -> String
  # Given a hash produce a unique string hash encoding for it
  def hash_hash(h)
    require 'digest/md5'

    ordered = h.sort.map { |i| i.class==Hash ? i.sort : i }
    return ordered.to_s
    Digest::MD5.hexdigest(Marshal::dump(ordered))
  end
end
