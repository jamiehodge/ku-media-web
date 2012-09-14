require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/reloader'

require 'slim'

require 'rake-pipeline'
require 'rake-pipeline/middleware'

class Base < Sinatra::Base
  
  enable :method_override
  
  use Rake::Pipeline::Middleware, 'Assetfile'
  
  register Sinatra::Namespace
  register Sinatra::Reloader if development?
  
  before do
    cache_control :public, :no_cache if request.get?
  end
  
  private
  
  def query
    params[:q]
  end
end
