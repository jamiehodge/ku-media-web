require_relative 'base'

require 'ku/media'

class Items < Base
  
  before do
    env['warden'] && env['warden'].authenticate!
  end
  
  namespace '/' do
    
    get do
      etag items_index.sum(:lock_version)
      last_modified items_index.first.updated_at unless items_index.empty?
    
      slim :'items/index', locals: { items: items_index }
    end
    
    post do
      @item = KU::Media::Item.create params[:item] || {}
    
      headers \
        'Location'         => url("/#{@item.id}"),
        'Content-Location' => url("/#{@item.id}")
      status 201
     
      slim :'items/show', locals: { item: @item }
    end
    
    namespace ':id' do
    
      before do
        @item = KU::Media::Item[params[:id]] || not_found
      end
    
      get do
        etag          @item.lock_version
        last_modified @item.updated_at
      
        slim :'items/show', locals: { item: @item }
      end
      
      put do
        @item.update params[:item] || {}
      
        etag          @item.lock_version
        last_modified @item.updated_at
        
        headers 'Content-Location' => url("/#{@item.id}")
      
        slim :'items/show', locals: { item: @item }
      end
      
      delete do
        @item.destroy
        
        etag items_index.sum(:lock_version)
        last_modified items_index.first.updated_at unless items_index.empty?
        
        headers 'Content-Location' => url('/')
      
        slim :'items/index', locals: { items: items_index }
      end
    end
  end
  
  private
  
  def items_index
    KU::Media::Item.search(params[:q]).paginate(params[:page] || 1, 12).reverse
  end
  
  def languages
    KU::Media::Language
  end
  
  def categories
    KU::Media::Category
  end
end