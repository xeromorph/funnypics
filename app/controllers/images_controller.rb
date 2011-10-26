class ImagesController < ApplicationController
  before_filter :params_clean

  # GET /images
  # GET /images.json
  def index
    default_view
   #@images = @images
    #.paginate(:include => :tags, :page => params[:page], :per_page => 5)
    #else
    # @images = Image.paginate(:include => :tags, :page => params[:page], :per_page => 5)
    #end
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @images }
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
#    @image = Image.find(params[:id])
    @image = Image.find_by_id(params[:id])
    
    respond_to do |format|
     if @image
      format.html # show.html.erb
      format.json { render json: @image }
     else
     format.html {redirect_to images_url, notice: 'Image not found.'}
     end
    end
  end

  # GET /images/new
  # GET /images/new.json
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/1/edit
  def edit
    @image = Image.find(params[:id])
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(params[:image])

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render json: @image, status: :created, location: @image }
      else
        format.html { render action: "new" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /images/1
  # PUT /images/1.json
  def update
    @image = Image.find(params[:id])

    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image = Image.find(params[:id])
    @image.destroy
#    default_view

    respond_to do |format|
      #format.html #{ redirect_to images_url, :params => params }
      format.js { }
      format.json { head :ok }
    end
  end
  
  def import
    # TODO: implement bulk image import from a predefined folder  
    require 'fileutils'
    require 'find'
    image_count = 0
    import_dir = "./pub/to_import/"
    imported_dir = "./pub/imported/"
    failed_dir = "./pub/failed/"
    Find.find(import_dir) do |file|
      next unless File.file?(file) and file =~ /.*\.(jpe?g|gif|png)/i
      relative_path = file.sub(import_dir,"")
      relative_dir = File.dirname(relative_path)
      image = Image.new
      image.img = File.open(file)
      image.description = "mass imported file"
      image.tag_names = relative_dir.scan(/\w+/i).join(",")
      if image.save
        image_count += 1
        relative_path.insert(0,imported_dir)
      else
        relative_path.insert(0,failed_dir)
      end
      FileUtils.makedirs(File.dirname(relative_path))
      FileUtils.mv(file,relative_path)
    end
    redirect_to images_path, :notice => "#{image_count} images were mass imported"
  end

  private
  #params_clean: delete blank params items
  def params_clean
    params.delete_if {|k,v| v.blank?}
  end
  def default_view
    @images = Image.includes(:tags).page(params[:page]).order("images.created_at desc")
    if params[:tag]
      @images = @images.where(["tags.name = ?",params[:tag]])
    end
  end
end
