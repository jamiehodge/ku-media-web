require_relative 'base'

require 'ku/media'

class Assets < Base
  
  before do
    env['warden'] && env['warden'].authenticate!
  end

  namespace '/' do
    
    namespace ':id' do
      
      before do
        @asset = KU::Media::Asset[params[:id]] || not_found
      end
      
      get do
        send_file @asset.path
      end
    end
  end
end