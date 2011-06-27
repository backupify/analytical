module Analytical
  module Modules
    class Marketo
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = :head_prepend
      end

      def init_javascript(location)
        init_location(location) do
          js = <<-HTML
          <!-- BEGIN Marketo Munchkin Tracking Code -->
          <script type="text/javascript">
            document.write('<scr'+'ipt type="text/javascript" src="' +
            document.location.protocol +
            '//munchkin.marketo.net/munchkin.js"><\/scr'+'ipt>');
          </script>
          <script>mktoMunchkin("#{options[:id]}");</script>
          <!-- END Marketo Munchkin Tracking Code -->
          HTML
          js
        end
      end

      def call_munchkin_function(function_name, args, sha1)
        <<-JS
          <script type="text/javascript">
            mktoMunchkinFunction(#{function_name}, #{args.to_json}, "#{sha1}");
          </script>
        JS
      end

    end
  end
end