$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'cacheify'
require 'spec'
require 'spec/autorun'


Cacheify.cache_store = :memory_store


Spec::Runner.configure do |config|
  
end
