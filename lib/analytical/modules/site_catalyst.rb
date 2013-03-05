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
          <script language="javascript" src="//nexus.ensighten.com/symantec/scode/om_code_min.js" type="text/javascript"></script>
          <!--<script language="javascript" src="#{options[:om_code]}" type="text/javascript"></script>-->

          <script language="javascript" src="//nexus.ensighten.com/symantec/scode/s_code_min.js" type="text/javascript"></script>
          <!--<script language="javascript" src="#{options[:s_code]}" type="text/javascript"></script>-->
          HTML

          js
        end
      end

      def track(*args)
        <<-JS
          <!-- SiteCatalyst code. Copyright 1997-2008 Omniture, Inc. More info available at http:\/\/www.omniture.com -->
          <script language="JavaScript" type="text/javascript"><!--
          /* You may give each page an identifying name, server, and channel on the next lines. */

          s.account=#{options[:report_suite]};
          s.pageName=#{options[:page_name]};
          s.server=#{options[:server]};
          s.prop2=#{options[:site_country]};
          s.prop3=#{options[:site_language]};
          s.prop41=#{options[:site_section]};
          s.prop46=#{options[:content_format]};
          s.prop47=#{options[:content_type]};
          s.prop48=#{options[:content_title]};

          /* Conversion Variables */
          s.eVar27=#{options[:site_country]};
          s.eVar28=#{options[:site_language]};
          s.eVar41=#{options[:site_section]};
          s.eVar49=#{options[:content_title]};

          /************* DO NOT ALTER ANYTHING BELOW THIS LINE ! **************/
          var s_code=s.t();if(s_code)document.write(s_code)//--></script>
          <script language="JavaScript" type="text/javascript"><!--
          if(navigator.appVersion.indexOf('MSIE')>=0)document.write(unescape('%3C')+'\!
          -'+'-')
          //--></script>
          <!--/DO NOT REMOVE/-->
          <!-- End SiteCatalyst code -->
        JS
      end

    end
  end
end