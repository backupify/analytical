require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe "Analytical::Api" do

  describe 'on initialization' do
    it 'should construct an api class for each module' do
      expect(Analytical::Modules::Console).to receive(:new).and_return(@console = double('console'))
      expect(Analytical::Modules::Google).to receive(:new).and_return(@google = double('google'))
      a = Analytical::Api.new :modules=>[:console, :google]
      expect(a.modules).to eq({
        :console=>@console,
        :google=>@google,
      })
    end
    it 'should pass the ssl option on to the module constructor' do
      expect(Analytical::Modules::Console).to receive(:new).with(hash_including(:ssl=>true)).and_return(@console = double('console'))
      Analytical::Api.new :modules=>[:console], :ssl=>true
    end
    describe 'with a session option' do
      before(:each) do
        @session = {}
      end
      it 'should create a new SessionCommandStore for each module' do
        expect(Analytical::SessionCommandStore).to receive(:new).with(@session, :console).and_return(@console_store = double('console_store'))
        expect(Analytical::SessionCommandStore).to receive(:new).with(@session, :google).and_return(@google_store = double('google_store'))
        expect(Analytical::Modules::Console).to receive(:new).with(:session_store=>@console_store, :session=>@session).and_return(double('console'))
        expect(Analytical::Modules::Google).to receive(:new).with(:session_store=>@google_store, :session=>@session).and_return(double('google'))
        Analytical::Api.new :modules=>[:console, :google], :session=>@session
      end
    end
  end

  describe 'with modules' do
    before(:each) do
      allow(Analytical::Modules::Console).to receive(:new).and_return(@console = double('console'))
      allow(Analytical::Modules::Google).to receive(:new).and_return(@google = double('google'))
      allow(Analytical::Modules::Clicky).to receive(:new).and_return(@clicky = double('clicky'))
      allow(Analytical::Modules::Chartbeat).to receive(:new).and_return(@chartbeat = double('chartbeat'))

      @api = Analytical::Api.new :modules=>[:console, :google]
    end

    describe '#track' do
      it 'should store the #track command for each module api class' do
        @api = Analytical::Api.new :modules=>[:console, :google, :clicky]

        expect(@console).to receive(:queue).with(:track, 'something', {:a=>1, :b=>2})
        expect(@clicky).to receive(:queue).with(:track, 'something', {:a=>1, :b=>2})
        expect(@google).to receive(:queue).with(:track, 'something', {:a=>1, :b=>2})

        @api.track('something', {:a=>1, :b=>2})
      end
    end

    describe '#identify' do
      it 'should store the #track command for each module api class' do
        @api = Analytical::Api.new :modules=>[:console, :google, :clicky]

        expect(@console).to receive(:queue).with(:identify, 'something', {:a=>1, :b=>2})
        expect(@clicky).to receive(:queue).with(:identify, 'something', {:a=>1, :b=>2})
        expect(@google).to receive(:queue).with(:identify, 'something', {:a=>1, :b=>2})

        @api.identify('something', {:a=>1, :b=>2})
      end
    end

    describe '#now' do
      it 'should call a command on each module and collect the results' do
        @api = Analytical::Api.new :modules=>[:console, :google, :clicky]

        expect(@console).to receive(:track).with('something', {:a=>1, :b=>2}).and_return('console track')
        expect(@clicky).to receive(:track).with('something', {:a=>1, :b=>2}).and_return('clicky track')
        expect(@google).to receive(:respond_to?).with(:track).and_return(false)
        expect(@google).not_to receive(:track)

        expect(@api.now.track('something', {:a=>1, :b=>2})).to eq("console track\nclicky track")
      end
    end

    describe 'when accessing a module by name' do
      it 'should return the module api object' do
        @api = Analytical::Api.new :modules=>[:console, :google, :clicky, :chartbeat]
        expect(@api.console).to eq(@console)
        expect(@api.clicky).to eq(@clicky)
        expect(@api.google).to eq(@google)
        expect(@api.chartbeat).to eq(@chartbeat)
      end
    end

    describe 'gathering javascript' do
      before(:each) do
        allow(@console).to receive(:init_location?).and_return(false)
        allow(@console).to receive(:initialized).and_return(false)
        allow(@console).to receive(:process_queued_commands).and_return([])
        allow(@google).to receive(:init_location?).and_return(false)
        allow(@google).to receive(:initialized).and_return(false)
        allow(@google).to receive(:process_queued_commands).and_return([])
      end

      describe '#head_prepend_javascript' do
        it 'should return the javascript' do
          expect(@console).to receive(:init_javascript).with(:head_prepend).and_return('console_a')
          expect(@google).to receive(:init_javascript).with(:head_prepend).and_return('google_a')
          expect(@api.head_prepend_javascript).to eq("console_agoogle_a")
        end
      end

      describe '#head_append_javascript' do
        it 'should return the javascript' do
          expect(@console).to receive(:init_javascript).with(:head_append).and_return('console_a')
          expect(@google).to receive(:init_javascript).with(:head_append).and_return('google_a')
          expect(@api.head_append_javascript).to eq("console_agoogle_a")
        end
        it 'should render an existing template for Rails 3.0' do
          @api.options[:javascript_helpers] = true

          expect(@api.options[:controller] ||= RSpec::Mocks::Double.new).to receive(:render_to_string) { |param| param[:file] }
          File.exist?(@api.head_append_javascript).should be true
        end
        it 'should not render an existing template if javascript_helpers is false' do
          @api.options[:javascript_helpers] = false
          expect(@api.options[:controller] ||= Object.new).not_to receive(:render_to_string)
          @api.head_append_javascript.should be_blank
        end
      end

      describe '#body_prepend_javascript' do
        it 'should return the javascript' do
          expect(@console).to receive(:init_javascript).with(:body_prepend).and_return('console_b')
          expect(@google).to receive(:init_javascript).with(:body_prepend).and_return('google_b')
          expect(@api.body_prepend_javascript).to eq("console_bgoogle_b")
        end
      end
      describe '#body_append_javascript' do
        it 'should return the javascript' do
          expect(@console).to receive(:init_javascript).with(:body_append).and_return('console_c')
          expect(@google).to receive(:init_javascript).with(:body_append).and_return('google_c')
          expect(@api.body_append_javascript).to eq("console_cgoogle_c")
        end
      end
      describe 'with stored commands' do
        before(:each) do
          allow(@console).to receive(:init_location?).and_return(true)
          allow(@console).to receive(:initialized).and_return(false)
          allow(@console).to receive(:track).and_return('console track called')
          allow(@console).to receive(:queue)
          allow(@console).to receive(:process_queued_commands).and_return(['console track called'])
          allow(@google).to receive(:init_location?).and_return(false)
          allow(@google).to receive(:initialized).and_return(true)
          allow(@google).to receive(:track).and_return('google track called')
          allow(@google).to receive(:queue)
          allow(@google).to receive(:process_queued_commands).and_return(['google track called'])
          @api.track('something', {:a=>1, :b=>2})
        end
        describe '#body_prepend_javascript' do
          it 'should return the javascript' do
            expect(@console).to receive(:init_javascript).with(:body_prepend).and_return('console_b')
            expect(@google).to receive(:init_javascript).with(:body_prepend).and_return('google_b')
            expect(@api.body_prepend_javascript).to eq("console_bgoogle_b\n<script type='text/javascript'>\nconsole track called\ngoogle track called\n</script>")
          end
        end
      end
    end
  end
end
