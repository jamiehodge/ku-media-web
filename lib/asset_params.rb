class AssetParams
  
  def initialize params
    @name = params[:filename]
    @tempfile = params[:tempfile]
  end
  
  def to_hash
    {
      name: @name,
      type: Rack::Mime.mime_type(File.basename(@name)),
      tempfile: @tempfile,
      size: @tempfile.size
    }
  end
end