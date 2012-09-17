require_relative 'base'

require 'ku/media'

class Collections < Base
  
  before do
    env['warden'].authenticate!
  end
  
  namespace '/' do
  
    get do      
      # etag collections_index.sum(:lock_version)
      # last_modified collections_index.first.updated_at unless collections_index.empty?
    
      slim :'collections/index', locals: { collections: collections_index }
    end
  
    post do
      @collection = KU::Media::Collection.create params[:collection] || {}
    
      headers \
        'Location'         => url("/#{@collection.id}"),
        'Content-Location' => url("/#{@collection.id}")
      status 201
     
      slim :'collections/show', locals: { collection: @collection }
    end
  
    namespace ':id' do
    
      before do
        @collection = KU::Media::Collection[params[:id]] || not_found
      end
    
      get do
        etag          @collection.lock_version
        last_modified @collection.updated_at
      
        slim :'collections/show', locals: { collection: @collection }
      end
    
      put do
        @collection.update params[:collection] || {}
      
        etag          @collection.lock_version
        last_modified @collection.updated_at
        
        headers 'Content-Location' => url("/#{@collection.id}")
      
        slim :'collections/show', locals: { collection: @collection }
      end
    
      delete do
        @collection.destroy
        
        etag collections_index.sum(:lock_version)
        last_modified collections_index.first.updated_at unless collections_index.empty?
        
        headers 'Content-Location' => url('/')
      
        slim :'collections/index', locals: { collections: collections_index }
      end
      
      namespace '/authors' do
        
        post do
          author = KU::Media::Group.find_or_create id: params[:author][:id]
          @collection.add_author author unless @collection.authors.include? author
          
          etag          @collection.lock_version
          last_modified @collection.updated_at
        
          headers 'Content-Location' => url("/#{@collection.id}")
      
          slim :'collections/show', locals: { collection: @collection }
        end
        
        namespace '/:id' do
          
          before do
            @author = KU::Media::Group[params[:id]] || not_found
          end
          
          delete do
            @collection.remove_author @author
            
            etag          @collection.lock_version
            last_modified @collection.updated_at
        
            headers 'Content-Location' => url("/#{@collection.id}")
      
            slim :'collections/show', locals: { collection: @collection }
          end
        end
      end
      
      namespace '/keywords' do
        
        post do
          keyword = KU::Media::Keyword.find_or_create name: params[:keyword][:name]
          @collection.add_keyword keyword unless @collection.keywords.include? keyword
          
          etag          @collection.lock_version
          last_modified @collection.updated_at
        
          headers 'Content-Location' => url("/#{@collection.id}")
      
          slim :'collections/show', locals: { collection: @collection }
        end
        
        namespace '/:id' do
          
          before do
            @keyword = KU::Media::Keyword[params[:id]] || not_found
          end
          
          delete do
            @collection.remove_keyword @keyword
            
            etag          @collection.lock_version
            last_modified @collection.updated_at
        
            headers 'Content-Location' => url("/#{@collection.id}")
      
            slim :'collections/show', locals: { collection: @collection }
          end
        end
      end
      
      namespace '/tags' do
        
        post do
          tag = KU::Media::Tag.find_or_create name: params[:tag][:name]
          @collection.add_tag tag unless @collection.tags.include? tag
          
          etag          @collection.lock_version
          last_modified @collection.updated_at
        
          headers 'Content-Location' => url("/#{@collection.id}")
      
          slim :'collections/show', locals: { collection: @collection }
        end
        
        namespace '/:id' do
          
          before do
            @tag = KU::Media::Tag[params[:id]] || not_found
          end
          
          delete do
            @collection.remove_tag @tag
            
            etag          @collection.lock_version
            last_modified @collection.updated_at
        
            headers 'Content-Location' => url("/#{@collection.id}")
      
            slim :'collections/show', locals: { collection: @collection }
          end
        end
      end
      
      namespace '/links' do
        
        post do
          link = KU::Media::Link.find_or_create url: params[:link][:url]
          @collection.add_link link unless @collection.links.include? link
          
          etag          @collection.lock_version
          last_modified @collection.updated_at
        
          headers 'Content-Location' => url("/#{@collection.id}")
      
          slim :'collections/show', locals: { collection: @collection }
        end
        
        namespace '/:id' do
          
          before do
            @link = KU::Media::Link[params[:id]] || not_found
          end
          
          delete do
            @collection.remove_link @link
            
            etag          @collection.lock_version
            last_modified @collection.updated_at
        
            headers 'Content-Location' => url("/#{@collection.id}")
      
            slim :'collections/show', locals: { collection: @collection }
          end
        end
      end
    end
  
    private
  
    def collections_index
      KU::Media::Collection.search(params[:q]).paginate(params[:page] || 1, 12).reverse
    end
    
    def languages
      KU::Media::Language.order(:name)
    end
    
    def categories
      KU::Media::Category
    end
  end
end

Collections.run! if $0 == __FILE__

