require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Example classes we'll use in specs

class Foo 
  def bar(something = nil)
    "#{rand(99999999)}#{something}"
  end
  
  def rab(something = nil)
    "#{rand(99999999)}#{something}"
  end
end

class Hoo
  def bar(something = nil)
    "#{rand(99999999)}#{something}"
  end
end

class Baz
  def boo
    "#{rand(99999999)}"
  end
end

describe "Cacheify" do
  before :all do
    Foo.extend Cacheify
    Hoo.extend Cacheify 

    Foo.cacheify :bar, :rab
    Hoo.cacheify :bar

    foo = Foo.new
    hoo = Hoo.new
    
    @foo_bar_1_call = foo.bar("hello")
    @foo_bar_2_call = foo.bar("hello")
    @foo_bar_diff_args_1_call = foo.bar("howdy")
    @foo_rab_1_call = foo.rab("hello")
    @hoo_bar_1_call = hoo.bar("hello")
    @hoo_bar_2_call = hoo.bar("hello")
  end

  it "should return cached result second time" do
    @foo_bar_1_call.should == @foo_bar_2_call
  end
  
  specify "cache should be scoped to class, method name and args" do
    @hoo_bar_1_call.should_not == @foo_bar_1_call
    @foo_rab_1_call.should_not == @foo_bar_1_call
    @foo_bar_diff_args_1_call.should_not == @foo_bar_1_call
    # @hoo_bar_1_call.should == @hoo_bar_2_call
  end

  context "Caching of instantiated object" do
    before do
      baz = Baz.new
      baz.extend Cacheify
      baz.cacheify :boo
      @baz_boo_1_call = baz.boo
      @baz_boo_2_call = baz.boo
    end

    it do
      @baz_boo_1_call.should == @baz_boo_2_call
    end
  end
end
