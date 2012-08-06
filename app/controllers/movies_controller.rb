class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort_headers = ["title", "release_date"]
    @sorted_by = ""
    if (@sort_headers.include? params[:sort_by]) then
      @sorted_by = params[:sort_by]
      session[:sort_by] = @sorted_by
    elsif (@sort_headers.include? session[:sort_by]) then
      @sorted_by = session[:sort_by]
      flash.keep
      redirect_to movies_path(params.merge(:sort_by => @sorted_by)) and return
    end

    @all_ratings = Movie.select(:rating).map(&:rating).uniq
    @ratings = []
    if params[:ratings].is_a?(Hash) then
      @ratings = params[:ratings].keys.reject do |x|
        !@all_ratings.include? x
      end
      session[:ratings] = @ratings
    elsif params[:ratings].is_a?(Array) then
      @ratings = params[:ratings].reject do |x|
        !@all_ratings.include? x
      end
      session[:ratings] = @ratings
    elsif session[:ratings].is_a?(Array) then
      @ratings = session[:ratings].reject do |x|
        !@all_ratings.include? x
      end
      flash.keep
      redirect_to movies_path(params.merge(:ratings  => @ratings)) and return
    end


    #@movies = Movie.all
    @movies = Movie.find(:all, :conditions  => ["rating in (?)", @ratings], :order => @sorted_by)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
