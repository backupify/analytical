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
            (function(){var d=document,u=((d.location.protocol==='https:')?'s':'')+'://inttrax.com/pixel.js?cid=#{options[:cid]}&trid=';
            d.write(unescape('%3Cscript src=%22http'+u+'%22 type=%22text/javascript%22%3E%3C/script%3E'));}());
          </script>
          <!-- Integrate Affiliate Script END -->
        JS
      end

    end
  end
end