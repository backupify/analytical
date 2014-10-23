require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Analytical::Modules::GoogleTagManager" do
  before(:each) do
    @parent = mock('api', :options=>{:google=>{:key=>'abc'}})
  end
  describe "on initialize" do
    it "should set the command_location" do
      a = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abc'
      a.tracking_command_location.should == [:head_prepend, :body_prepend]
    end
    it 'should set the options' do
      a = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abc'
      a.options.should == {:key=>'abc', :parent=>@parent}
    end
  end

  describe '#event' do
    it 'should return the event javascript' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      result = @api.event('someEventName', {:foo=>'bar'})
      match = result.match /dataLayer.push\(\{(.+)\}/ 
      match.should_not be_nil
      # parse the JSON to work around varying order of key/value pairs in analytical's result string
      JSON.parse("{#{ match[1] }}").should == {"event"=>"someEventName", "foo" =>"bar"}
    end
    it 'should include attribute values' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      result = @api.event('someEventName', {:value=>555, :more=>'info'})
      match = result.match /dataLayer.push\(\{(.+)\}/ 
      match.should_not be_nil
      # parse the JSON to work around varying order of key/value pairs in analytical's result string
      JSON.parse("{#{ match[1] }}").should == {"event"=>"someEventName", "value" => 555, "more" => "info"}
    end
    it 'should not include attributes if there is no value' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      @api.event('someEventName').should ==  "dataLayer.push({\"event\":\"someEventName\"});"
    end
    it 'should not include attributes if it is not a hash' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      @api.event('someEventName', 555).should ==  "dataLayer.push({\"event\":\"someEventName\"});"
    end
  end

   describe '#associate_lead' do
    it 'should return the event javascript' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      @api.associate_lead('name@domain.com', 'someEncryptedString').should ==  "dataLayer.push({'event': 'associateLead', 'leadEmail': 'name@domain.com', 'authKey': 'someEncryptedString'});"
    end
    it 'should return an empty string if both email and the sha1 are not present' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      @api.associate_lead('name@domain.com', '').should ==  ''
    end
  end
end