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
      @api.event('someEventName', {:foo=>'bar'}).should ==
      <<-HTML
        var dataLayerEventData = {\"foo\":\"bar\"};
        dataLayerEventData['event'] = "someEventName";
        dataLayer.push(dataLayerEventData);
        HTML
    end
    it 'should include attribute values' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      @api.event('someEventName', {:foo=>'bar', :more=>'info'}).should ==
      <<-HTML
        var dataLayerEventData = {\"foo\":\"bar\",\"more\":\"info\"};
        dataLayerEventData['event'] = "someEventName";
        dataLayer.push(dataLayerEventData);
        HTML
    end
    it 'should not include attributes if there is no value' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      @api.event('someEventName').should ==
      <<-HTML
        var dataLayerEventData = {};
        dataLayerEventData['event'] = "someEventName";
        dataLayer.push(dataLayerEventData);
        HTML
    end
    it 'should not include attributes if it is not a hash' do
      @api = Analytical::Modules::GoogleTagManager.new :parent=>@parent, :key=>'abcdef'
      @api.event('someEventName', 555).should ==
      <<-HTML
        var dataLayerEventData = {};
        dataLayerEventData['event'] = "someEventName";
        dataLayer.push(dataLayerEventData);
        HTML
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