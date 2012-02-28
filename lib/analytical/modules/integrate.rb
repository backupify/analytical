module Analytical
  module Modules
    class Integrate
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = :head_append
      end

      def init_javascript(location)
        init_location(location) do
          js = <<-HTML
          HTML

          integrate_commands = []

          @command_store.commands.each do |c|
            if c[0] == :integrate_lead
              integrate_commands << integrate_lead(*c[1..-1])
            end
          end

          js += "\n" + integrate_commands.join("\n")
          @command_store.commands = @command_store.commands.delete_if {|c| c[0] == :integrate_lead }

          js
        end
      end

      def integrate_lead()
        <<-JS
          <!-- Integrate Affiliate Script BEGIN -->
          <script type="text/javascript">
            (function() {
              function async_load(){
                var s = document.createElement('script');
                s.type = 'text/javascript';
                s.async = true;
                s.src = 'http://inttrax.com/pixel.js?cid=#{options[:cid]}&trid=';
                var x = document.getElementsByTagName('script')[0];
                x.parentNode.insertBefore(s, x);
              }
              if (window.attachEvent)
                window.attachEvent('onload', async_load);
              else
              window.addEventListener('load', async_load, false);
            })();
          </script>
          <!-- Integrate Affiliate Script END -->
        JS
      end

    end
  end
end