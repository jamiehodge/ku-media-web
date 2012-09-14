require 'ku/media'

Warden::Manager.serialize_into_session {|user| user.id }

Warden::Manager.serialize_from_session {|id| KU::Media::Person[id] }

Warden::Manager.before_failure do |env, opts|
  env['REQUEST_METHOD'] = 'POST'
end

Warden::Strategies.add :password do
  
  def valid?
    params['user'] && params['user']['id'] && params['user']['password']
  end
  
  def authenticate!
    user = KU::Media::Person.authenticate \
      params['user']['id'],
      params['user']['password']
    user.nil? ? fail! : success!(user, "Welcome #{user.full_name}")
  end
end

Warden::Strategies.add :basic do
  
  def auth
    @auth ||= Rack::Auth::Basic::Request.new env
  end
  
  def valid?
    auth.provided? && auth.basic? && auth.credentials
  end
  
  def authenticate!
    user = User.authenticate(*auth.credentials)
    user.nil? ? fail! : success!(user)
  end
  
  def store?
    false
  end
end
