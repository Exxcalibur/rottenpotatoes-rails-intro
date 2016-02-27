class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.ratings
    @movies = Movie.order(params[:sort]).all
    @sort_by = params[:sort]
    @ratings_hash = Hash[*@all_ratings.map {|key| [key, 1]}.flatten]
    
    if (params[:session] == "clear")
      session[:sort] = nil
      session[:ratings] = nil
    end
    
    if(params[:ratings] != nil)
      @ratings_hash = params[:ratings]
      @movies = @movies.where(:rating => @ratings_hash.keys)
      session[:ratings] = @ratings_hash
    end
    
    if (params[:sort] != nil)
      if (params[:sort] == "title")
        session[:sort] = "title"
      elsif (params[:sort] == "release_date")
        session[:sort] = "release_date"
      end
    end
    
    if (params[:sort] == nil || params[:ratings] == nil)
      redirect_hash = (session[:ratings] != nil) ? Hash[*session[:ratings].keys.map {|key| ["ratings[#{key}]", 1]}.flatten] : { :ratings => @ratings_hash }
      redirect_hash[:sort] = (session[:sort] != nil) ? session[:sort] : "none"
      redirect_to movies_path(redirect_hash) and return
    end
    
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
  
  def sort_by_title
    @movies = Movie.order(:title)
    #redirect_to movies_path
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
