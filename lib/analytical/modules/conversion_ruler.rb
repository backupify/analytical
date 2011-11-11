module Analytical
  module Modules
    class ConversionRuler
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = :body_append
      end

      def init_javascript(location)
        init_location(location) do
          js = <<-HTML
          HTML

          conversion_commands = []

          @command_store.commands.each do |c|
            if c[0] == :cr_track
              conversion_commands << cr_track(*c[1..-1])
            end
          end

          js += "\n" + conversion_commands.join("\n")
          @command_store.commands = @command_store.commands.delete_if {|c| c[0] == :cr_track }

          js
        end
      end

      def cr_track(track_id = nil, cr_text = nil, cr_amount = nil)
        text = nil
        unless cr_text.nil?
          text = "var crtext0 = '#{cr_text}';"
        end

        amount = nil
        unless cr_amount.nil?
          amount = "var cramount0 = '#{cr_amount}';"
        end

        <<-JS
          <!-- WPMG ROI Tracking Script BEGIN -->
          <script type="text/javascript">
            (function(){var d=document,u=((d.location.protocol==='https:')?'s':'')+'://www.conversionruler.com/bin/js.php?siteid=6302';
            d.write(unescape('%3Cscript src=%22http'+u+'%22 type=%22text/javascript%22%3E%3C/script%3E'));}());
          </script>
          <script type="text/javascript">
            #{amount}
            #{text}
            cr_track(#{("'"<<track_id<<"'" unless track_id.nil?)});
          </script>
          <noscript>
            <div style="position: absolute; left: 0">
              <img src="https://www.conversionruler.com/bin/tracker.php?siteid=6302&amp;nojs=1#{(track_id.nil?) ? '' : '&amp;actn='<<track_id}" alt="" width="1" height="1" />
            </div>
          </noscript>
          <!-- WPMG ROI Tracking Script END -->
        JS
      end

    end
  end
end