require_relative 'helper'

describe 'Sessions' do
  
  before do
    Capybara.reset_sessions!
    visit '/'
  end

  it 'must present new session form' do
    assert page.has_selector?('form.session.new')
  end
  
  describe 'sign in' do
    
    describe 'success' do
      
      before do
        within 'form.session.new' do
          fill_in 'login', with: ENV['LDAP_ADMIN_LOGIN']
          fill_in 'password', with: ENV['LDAP_ADMIN_PASSWORD']
          click_button 'sign in'
        end
      end
      
      it 'must redirect to attempted path' do
        current_path.must_equal '/'
      end
      
      it 'wont present new session form' do
        refute page.has_selector?('form.session.new')
      end
      
      it 'must present delete session form' do
        assert page.has_selector?('form.session.delete')
      end
    end
    
    describe 'failure' do
      
      before do
        within 'form.session.new' do
          fill_in 'login', with: 'foo'
          fill_in 'password', with: 'bar'
          click_button 'sign in'
        end
      end
      
      it 'must redirect to POST /sessions/' do
        current_path.must_equal '/sessions/'
      end
      
      it 'must present new session form' do
        assert page.has_selector?('form.session.new')
      end
    end
  end
end