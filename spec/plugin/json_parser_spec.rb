require File.expand_path("spec_helper", File.dirname(File.dirname(__FILE__)))

describe "json_parser plugin" do 
  before do
    app(:json_parser) do |r|
      r.params['a']['b'].to_s
    end
  end

  it "parses incoming json if content type specifies json" do
    body('rack.input'=>StringIO.new('{"a":{"b":1}}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').should == '1'
  end

  it "doesn't affect parsing of non-json content type" do
    body('rack.input'=>StringIO.new('a[b]=1'), 'REQUEST_METHOD'=>'POST').should == '1'
  end

  it "returns 400 for invalid json" do
    req('rack.input'=>StringIO.new('{"a":{"b":1}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').should == [400, {}, []]
  end
end

describe "json_parser plugin" do 
  it "handles empty request bodies" do
    app(:json_parser) do |r|
      r.params.length.to_s
    end
    body('rack.input'=>StringIO.new(''), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').should == '0'
  end

  it "supports :error_handler option" do
    app(:bare) do
      plugin(:json_parser, :error_handler=>proc{|r| r.halt [401, {}, ['bad']]})
      route do |r|
        r.params['a']['b'].to_s
      end
    end
    req('rack.input'=>StringIO.new('{"a":{"b":1}'), 'CONTENT_TYPE'=>'text/json', 'REQUEST_METHOD'=>'POST').should == [401, {}, ['bad']]
  end
end
