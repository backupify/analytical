module Analytical
  module Modules
    class SiteCatalyst
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = :head_append
      end

      def init_javascript(location)
        init_location(location) do
          js = <<-HTML
          <script language="javascript" src="#{options[:om_code]}" type="text/javascript"></script>

          <script language="javascript" src="#{options[:s_code]}" type="text/javascript"></script>
          HTML

          identify_commands = []
          @command_store.commands.each do |c|
            if c[0] == :identify
              identify_commands << identify(*c[1..-1])
            end
          end
          js = identify_commands.join("\n") + "\n" + js
          @command_store.commands = @command_store.commands.delete_if {|c| c[0] == :identify }

          js
        end
      end

      def identify(*args)
        code = <<-HTML
          <!-- SiteCatalyst code. Copyright 1997-2008 Omniture, Inc. More info available at http:\/\/www.omniture.com -->

          <script language="javascript" type="text/javascript"><!--
          /* You may give each page an identifying name, server, and channel on the next lines. */

          s.account="#{options[:report_suite]}";
          s.pageName=metaData['page_name'];
          s.server="#{options[:server]}";
          s.prop2="#{options[:site_country]}";
          s.prop3="#{options[:site_language]}";
          s.prop41="#{options[:site_section]}";
          s.prop46="#{options[:content_format]}";
          s.prop47="#{options[:content_type]}";
          s.prop48=document.title;

          /* Conversion Variables */
          s.eVar27="#{options[:site_country]}";
          s.eVar28="#{options[:site_language]}";
          s.eVar41="#{options[:site_section]}";
          s.eVar49=document.title;

          /************* DO NOT ALTER ANYTHING BELOW THIS LINE ! **************/
          var s_code=s.t();if(s_code)document.write(s_code)//--></script>
          <script language="javascript" type="text/javascript"><!--
          if(navigator.appVersion.indexOf('MSIE')>=0)document.write(unescape('%3C')+'\!-'+'-')
          //--></script>
          <!--/DO NOT REMOVE/-->
          <!-- End SiteCatalyst code -->
        HTML

        code
      end

    end
  end
end