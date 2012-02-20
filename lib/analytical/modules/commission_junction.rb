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
            #if c[0] == :pixel_track
            if c[0] == :lead
              #cj_commands << pixel_track(*c[1..-1])
              cj_commands << lead(*c[1..-1])
            elsif c[0] == :payment
              cj_commands << payment(*c[1..-1])
            end
          end

          js += "\n" + cj_commands.join("\n")
          #@command_store.commands = @command_store.commands.delete_if {|c| c[0] == :pixel_track }
          @command_store.commands = @command_store.commands.delete_if {|c| c[0] == :lead || c[0] == :payment }

          js
        end
      end

      def lead(name, user_id, domain_size = 0)
        lead_size = 1
        unless domain_size == 0
          case domain_size
            when 0..9 then lead_size = 1
            when 10..99 then lead_size = 2
            else lead_size = 3
          end
        end

        pixel_track(name, user_id, {:item1 => lead_size, :amt1 => 0, :qty1 => 1})
      end

      def payment(name, user_id, users_count)
        pixel_track(name, user_id, {:item1 => 1, :amt1 => (users_count * 3), :qty1 => users_count})
      end

      def pixel_track(name, user_id, opts = {})
        if cj = options[name.to_sym]
          cj.symbolize_keys!
          js = <<-HTML
            <!-- Commission Junction BEGIN -->
            <script type="text/javascript">
              (function() {
                var url = 'https://www.emjcd.com/u?CID=#{cj[:cid]}&OID=#{user_id}&TYPE=#{cj[:type]}&ITEM1=#{opts[:item1]}&AMT1=#{opts[:amt1]}&QTY1=#{opts[:qty1]}&CURRENCY=#{cj[:currency]}&METHOD=#{cj[:method]}';
                var pixel = document.createElement("img");
                pixel.src = url;
                pixel.width = 20;
                pixel.height = 1;
                document.getElementsByTagName('body')[0].appendChild(pixel);
              })();
            </script>
            <noscript>
              <div style="position: absolute; left: 0">
                <img src="https://www.emjcd.com/u?CID=#{cj[:cid]}&OID=#{user_id}&TYPE=#{cj[:type]}&ITEM1=#{opts[:item1]}&AMT1=#{opts[:amt1]}&QTY1=#{opts[:qty1]}&CURRENCY=#{cj[:currency]}&METHOD=#{cj[:method]}" alt="" width="20" height="1" />
              </div>
            </noscript>
            <!-- Commission Junction END -->
          HTML
          js
        else
          "<!-- No Commission Junction pixel for: #{name} -->"
        end
      end

    end
  end
end
