class ImagesController < ApplicationController
  before_filter :persist_params
  respond_to :html, :js

  def index
    default_view
    respond_with @images
  end

  def show
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

  def new
    respond_with @image = Image.new
  end

  def edit
    @image = Image.find(params[:id])
  end

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

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    default_view
    #@images.each {|i| puts i.id}
    #puts @image.id
    #puts @tag.to_s
    #puts @page.to_s
    #puts params
    #@images.delete(@image)

    respond_with @images
    #respond_to do |format|
      #format.html #{ redirect_to images_url, :params => params }
     # format.js { }
     # format.json { head :ok }
    #end
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
      next unless File.file?(file) and file =~ /\.(jpe?g|gif|png)$/i
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
  def url_options
    {:tag => @tag, :page => @page}.merge(super)
  end

  private
  #params_clean: delete blank params items
  def persist_params
    params.delete_if {|k,v| v.blank?}
    @page = params[:page] || 1
    @tag = params[:tag]
  end
  def default_view
    @images = Image.order("images.created_at desc")
    if @tag
      @images = @images.includes(:tags).where(["tags.name = ?", @tag])
    end
    @images = @images.page(@page)
  end
end
