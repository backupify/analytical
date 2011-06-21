module Analytical
  module Modules
    class GoogleOptimizer
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = :head_prepend
      end

      def init_javascript(location)
        init_location(location) do
          js = <<-HTML
          HTML
          optimizer_commands = []
          @command_store.commands.each do |c|
            if c[0] == :conversion
              optimizer_commands << conversion(*c[1..-1])
            elsif c[0] == :tracking
              optimizer_commands << tracking(*c[1..-1])
            elsif c[0] == :control
              optimizer_commands << control(*c[1..-1])
            end
          end
          js = optimizer_commands.join("\n") + "\n" + js
          @command_store.commands = @command_store.commands.delete_if {|c| c[0] == :conversion || c[0] == :tracking || c[0] == :control }
          js
        end
      end

      def control(*args)
        extra_js = nil
        if(options[:cross_domain])
          extra_js = "<script>_udn = \".#{options[:cross_domain]}\";</script>"
        end

        js = <<-HTML
          #{extra_js}
          <!-- Analytical Init:  Google Website Optimizer Control Script -->
          <script>
          function utmx_section(){}function utmx(){}
      		(function(){var k='#{options[:key]}',d=document,l=d.location,c=d.cookie;function f(n){
      		if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return escape(c.substring(i+n.
      		length+1,j<0?c.length:j))}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
      		d.write('<sc'+'ript src="'+
      		'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
      		+'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
      		+new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
      		'" type="text/javascript" charset="utf-8"></sc'+'ript>')})();
      		</script><script>utmx("url",'A/B');</script>
      		<!-- End of Google Website Optimizer Control Script -->
        HTML
        js
      end

      def tracking(*args)
        extra_js = nil
        if(options[:cross_domain])
          extra_js = "_gaq.push(['gwo._setDomainName', '.#{options[:cross_domain]}']);"
        end

        js = <<-HTML
      		<!-- Analytical Init: Google Website Optimizer Tracking Script -->
          <script type="text/javascript">
            var _gaq = _gaq || [];
            _gaq.push(['gwo._setAccount', '#{options[:account]}']);
            #{extra_js}
            _gaq.push(['gwo._trackPageview', '/#{options[:key]}/test']);
            (function() {
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
            })();
          </script>
          <!-- End of Google Website Optimizer Tracking Script -->
        HTML
        js
      end

      def conversion(*args)
        extra_js = nil
        if(options[:cross_domain])
          extra_js = "_gaq.push(['gwo._setDomainName', '.#{options[:cross_domain]}']);"
        end

        js = <<-HTML
        <!-- Analytical Init:  Google Website Optimizer Conversion Script -->
        <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['gwo._setAccount', '#{options[:account]}']);
          #{extra_js}
          _gaq.push(['gwo._trackPageview', '/#{options[:key]}/goal']);
          (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
        </script>
        <!-- End of Google Website Optimizer Conversion Script -->
        HTML
        js
      end

    end
  end
end
