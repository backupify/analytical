module Analytical
  module Modules
    class CommissionJunction
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = :body_append
      end

      def init_javascript(location)
        init_location(location) do
          js = <<-HTML
          HTML

          cj_commands = []

          @command_store.commands.each do |c|
            if c[0] == :pixel_track
              cj_commands << pixel_track(*c[1..-1])
            end
          end

          js += "\n" + cj_commands.join("\n")
          @command_store.commands = @command_store.commands.delete_if {|c| c[0] == :pixel_track }

          js
        end
      end

      def pixel_track(user_id, domain_size = 0)
        lead_size = 1
        if(!domain_size == 0)
          case domain_size
            when 0..9 then lead_size = 1
            when 10..99 then lead_size = 2
            else lead_size = 3
          end
        end

        <<-JS
          <!-- Commission Junction BEGIN -->
          <script type="text/javascript">
            var url = 'https://www.emjcd.com/u?CID=1521498&OID=#{user_id}&TYPE=348333&ITEM1=#{lead_size}&AMT1=0&QTY1=1&CURRENCY=USD&METHOD=IMG';
            var pixel = document.createElement("img");
            pixel.src = url;
            pixel.width = 20;
            pixel.height = 1;
            document.getElementsByTagName('body')[0].appendChild(pixel);
          </script>
          <noscript>
            <div style="position: absolute; left: 0">
              <img src="https://www.emjcd.com/u?CID=1521498&OID=#{user_id}&TYPE=348333&ITEM1=#{lead_size}&AMT1=0&QTY1=1&CURRENCY=USD&METHOD=IMG" alt="" width="20" height="1" />
            </div>
          </noscript>
          <!-- Commission Junction END -->
        JS
      end

    end
  end
end