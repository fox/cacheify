require 'active_support'
require 'digest/md5'

module Cacheify
  def self.cache_store=(store_option)
    @@cache_store = ActiveSupport::Cache.lookup_store(store_option)
  end

  def self.cache # :nodoc: 
    @cache_store ||= defined?(Rails) ? Rails.cache : ActiveSupport::Cache.lookup_store(:file_store, "tmp/cacheify")
  end

  def cache_method(*symbols)
    options = symbols.last.is_a?(Hash) ? symbols.delete(symbols.last) : {}

    symbols.each do |method|
      non_cached_method = "_non_cached_#{method}".to_sym 
      return if respond_to? non_cached_method # cached already, skip it
      
      alias_method non_cached_method, method
      
      define_method(method) do |*args, &block|
        cache_name = Digest::MD5.hexdigest(args.inspect)
        marshalled_result = Cacheify.cache.fetch(cache_name, options) do 
          send(non_cached_method, *args, &block)
        end
      end
    end
  end

  alias :cache_methods :cache_method
end
