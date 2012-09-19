require_relative 'base'
require_relative '../lib/asset_params'

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
      
      namespace '/authors' do
        
        post do
          author = KU::Media::Person.find_or_create id: params[:author][:id]
          @item.add_author author unless @item.authors.include? author
          
          etag          @item.lock_version
          last_modified @item.updated_at
        
          headers 'Content-Location' => url("/#{@item.id}")
      
          slim :'items/show', locals: { item: @item }
        end
        
        namespace '/:id' do
          
          before do
            @author = KU::Media::Person[params[:id]] || not_found
          end
          
          delete do
            @item.remove_author @author
            
            etag          @item.lock_version
            last_modified @item.updated_at
        
            headers 'Content-Location' => url("/#{@item.id}")
      
            slim :'items/show', locals: { item: @item }
          end
        end
      end
      
      namespace '/keywords' do
        
        post do
          keyword = KU::Media::Keyword.find_or_create name: params[:keyword][:name]
          @item.add_keyword keyword unless @item.keywords.include? keyword
          
          etag          @item.lock_version
          last_modified @item.updated_at
        
          headers 'Content-Location' => url("/#{@item.id}")
      
          slim :'items/show', locals: { item: @item }
        end
        
        namespace '/:id' do
          
          before do
            @keyword = KU::Media::Keyword[params[:id]] || not_found
          end
          
          delete do
            @item.remove_keyword @keyword
            
            etag          @item.lock_version
            last_modified @item.updated_at
        
            headers 'Content-Location' => url("/#{@item.id}")
      
            slim :'items/show', locals: { item: @item }
          end
        end
      end
      
      namespace '/tags' do
        
        post do
          tag = KU::Media::Tag.find_or_create name: params[:tag][:name]
          @item.add_tag tag unless @item.tags.include? tag
          
          etag          @item.lock_version
          last_modified @item.updated_at
        
          headers 'Content-Location' => url("/#{@item.id}")
      
          slim :'items/show', locals: { item: @item }
        end
        
        namespace '/:id' do
          
          before do
            @tag = KU::Media::Tag[params[:id]] || not_found
          end
          
          delete do
            @item.remove_tag @tag
            
            etag          @item.lock_version
            last_modified @item.updated_at
        
            headers 'Content-Location' => url("/#{@item.id}")
      
            slim :'items/show', locals: { item: @item }
          end
        end
      end
      
      namespace '/links' do
        
        post do
          link = KU::Media::Link.find_or_create url: params[:link][:url]
          @item.add_link link unless @item.links.include? link
          
          etag          @item.lock_version
          last_modified @item.updated_at
        
          headers 'Content-Location' => url("/#{@item.id}")
      
          slim :'items/show', locals: { item: @item }
        end
        
        namespace '/:id' do
          
          before do
            @link = KU::Media::Link[params[:id]] || not_found
          end
          
          delete do
            @item.remove_link @link
            
            etag          @item.lock_version
            last_modified @item.updated_at
        
            headers 'Content-Location' => url("/#{@item.id}")
      
            slim :'items/show', locals: { item: @item }
          end
        end
      end
      
      namespace '/asset' do
        
        put do
          @item.asset = KU::Media::Asset.new AssetParams.new(params[:asset]).to_hash
          
          etag          @item.lock_version
          last_modified @item.updated_at
        
          headers 'Content-Location' => url("/#{@item.id}")
      
          slim :'items/show', locals: { item: @item }
        end
        
        delete do
          @item.asset.destroy
          
          etag          @item.lock_version
          last_modified @item.updated_at
        
          headers 'Content-Location' => url("/#{@item.id}")
      
          slim :'items/show', locals: { item: @item }
        end
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