require 'active_support'
require 'digest/md5'

##
# Enables caching of method calls
module Cacheify
  ##
  # Set cache store to be used by Cachify (or leave it be to use defaults).
  # 
  # The default is FileStore tmp/cacheify or, if you're running 
  # inside Rails app, whatever Rails is using.
  #
  # === Parameters
  # store options as understood by ActiveSupport::Cache#lookup_store
  def self.cache_store=(store_option)
    @cache_store = ActiveSupport::Cache.lookup_store(store_option)
  end

  def self.cache # :nodoc: 
    @cache_store ||= defined?(Rails) ? Rails.cache : ActiveSupport::Cache.lookup_store(:file_store, "tmp/cacheify")
  end

  ##
  # Cache results of methods.
  #
  # === Parameters
  # * method names to cache
  # * optionally, last argument can be a hash of options passed to ActiveSupport::Cache::Store for caching. 
  #
  # === Example
  # cache_method :big_calculation, :expires_in => 5.minutes
  def cacheify(*symbols)
    (self.is_a?(Class) ? self : metaclass).class_eval do
      options = symbols.extract_options!

      symbols.each do |method|
        non_cached_method = "_non_cached_#{method}".to_sym 
        return if method_defined?(non_cached_method) # cached already, skip it
        alias_method non_cached_method, method
        
        define_method(method) do |*args, &block|
          cache_name = Digest::MD5.hexdigest "#{self.class.name}#{method}#{args.inspect}"
          marshalled_result = Cacheify.cache.fetch(cache_name, options) do 
            send(non_cached_method, *args, &block)
          end
        end
      end
    end
  end

  def self.included(obj)
    obj.extend Cacheify
  end
end
