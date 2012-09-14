require_relative 'base'

class Sessions < Base
  
  get '/' do
    redirect '/'
  end

  post '/' do
    env['warden'].authenticate!
    
    redirect session['attempted_path']
  end
  
  delete '/' do
    env['warden'].logout
    
    redirect '/'
  end
  
  post '/unauthenticated' do
    attempted_path = env['warden.options'][:attempted_path]
    session[:attempted_path] = env['warden.options'][:attempted_path]
    
    slim :'sessions/new'
  end
end
