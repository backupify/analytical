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

          marketo_commands = []

          @command_store.commands.each do |c|
            if c[0] == :associate_lead
              marketo_commands << associate_lead(*c[1..-1])
            end
          end

          js += "\n" + marketo_commands.join("\n")
          @command_store.commands = @command_store.commands.delete_if {|c| c[0] == :associate_lead }

          js
        end
      end

      def associate_lead(email, sha1)
        <<-JS
          <script type="text/javascript">
            mktoMunchkinFunction('associateLead', { 'Email': "#{email}" }, "#{sha1}");
          </script>
        JS
      end

    end
  end
end