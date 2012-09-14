require_relative 'helper'
require_relative '../items'

describe Items do
  include Rack::Test::Methods
  
  def app
    Items
  end
  
  let(:params) {{ title: 'foo', description: 'bar', collection_id: KU::Media::Collection.first.id, category_id: 100, language_id: 'en' }} 
  let(:item) { KU::Media::Item.create params }
  
  describe '/' do
    
    describe 'GET' do
      
      before do 
        item
        get '/' 
      end
      
      it 'returns 200 OK' do
        last_response.status.must_equal 200
      end
      
      describe 'headers' do
        
        let(:headers) { last_response.headers }
        
        it 'return cache control' do
          headers.must_include 'Cache-Control'
        end
        
        it 'returns etag' do
          headers.must_include 'ETag'
        end
      
        it 'returns last modified' do
          headers.must_include 'Last-Modified'
        end
      end
      
      describe 'body' do
        
        let(:body) { Nokogiri::HTML last_response.body }
        
        it 'returns item' do
          body.css('ol.collection').wont_be :empty?
        end
      end
    end
    
    describe 'POST' do
      
      before do 
        post '/', item: params
      end
      
      it 'returns 201 Created' do
        last_response.status.must_equal 201
      end
      
      describe 'headers' do
        
        let(:headers) { last_response.headers }
        
        it 'returns location' do
          headers.must_include 'Location'
        end
        
        it 'returns content-location' do
          headers.must_include 'Content-Location'
        end
      end
      
      describe 'body' do
        
        let(:body) { Nokogiri::HTML last_response.body }
        
        it 'returns item' do
          body.css('article').wont_be :empty?
        end
      end
    end
    
    describe ':id' do
    
      before do
        item
      end
      
      describe 'GET' do
        
        before { get "/#{item.id}" }
        
        it 'returns 200 OK' do
          last_response.status.must_equal 200
        end
        
        describe 'headers' do
        
          let(:headers) { last_response.headers }
        
          it 'return cache control' do
            headers.must_include 'Cache-Control'
          end
        
          it 'returns etag' do
            headers.must_include 'ETag'
          end
      
          it 'returns last modified' do
            headers.must_include 'Last-Modified'
          end
        end
        
        describe 'body' do
        
          let(:body) { Nokogiri::HTML last_response.body }
        
          it 'returns item' do
            body.css('article').wont_be :empty?
          end
        end
      end
      
      describe 'PUT' do
        
        before { put "/#{item.id}", item: params.merge(title: 'baz') }
        
        it 'returns 200 OK' do
          last_response.status.must_equal 200
        end
        
        describe 'headers' do
        
          let(:headers) { last_response.headers }
        
          it 'returns content location' do
            headers.must_include 'Content-Location'
          end
        
          it 'returns etag' do
            headers.must_include 'ETag'
          end
      
          it 'returns last modified' do
            headers.must_include 'Last-Modified'
          end
        end
        
        describe 'body' do
        
          let(:body) { Nokogiri::HTML last_response.body }
        
          it 'returns item' do
            body.css('article').wont_be :empty?
          end
        end
      end
      
      describe 'DELETE' do
        
        before { delete "/#{item.id}" }
        
        it 'returns 200 OK' do
          last_response.status.must_equal 200
        end
        
        describe 'headers' do
        
          let(:headers) { last_response.headers }
        
          it 'returns content location' do
            headers.must_include 'Content-Location'
          end
        
          it 'returns etag' do
            headers.must_include 'ETag'
          end
      
          it 'returns last modified' do
            headers.must_include 'Last-Modified'
          end
        end
        
        describe 'body' do
        
          let(:body) { Nokogiri::HTML last_response.body }
        
          it 'returns item' do
            body.css('ol.collection').wont_be :empty?
          end
        end
      end
    end
  end
end
