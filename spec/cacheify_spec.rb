require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# Example class we'll use in specs
class Foo 
  def bar(something = nil)
    "#{rand(99999999)}#{something}"
  end
end

describe "Cacheify" do
  before :all do
    Foo.extend Cacheify
    Foo.cacheify :bar, :hello => "Friend"
    
    @foo = Foo.new
    @first_call = @foo.bar("hello")
  end

  context "calling method twice on a cachified object" do
    before do
      @second_call = @foo.bar("hello")
    end
    
    it "should return cached result second time" do
      @first_call.should == @second_call
    end
  end
end
