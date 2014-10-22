module Analytical
  module Modules
    class GoogleTagManager
      include Analytical::Modules::Base

      def initialize(options={})
        super
        @tracking_command_location = [:head_prepend, :body_prepend]
      end

      def init_javascript(location)

        init_location(location) do
          case location.to_sym
            when :head_prepend
              js = <<-HTML
              <!-- Google Data Layer -->
              <script>dataLayer = [];</script>
              <!-- End Google Data Layer -->
              HTML
              js
            when :body_prepend
              js = <<-HTML
              <!-- Google Tag Manager -->
              <noscript><iframe src="//www.googletagmanager.com/ns.html?id=#{options[:key]}"
              height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
              <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
              new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
              j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
              '//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
              })(window,document,'script','dataLayer','#{options[:key]}');</script>
              <!-- End Google Tag Manager -->
              HTML

              gtm_commands = []

              @command_store.commands.each do |c|
                if c[0] == :associate_lead
                  gtm_commands << associate_lead(*c[1..-1])
                end
              end

              js += "\n" + gtm_commands.join("\n")
              @command_store.commands = @command_store.commands.delete_if {|c| c[0] == :associate_lead }
              js
          end
        end
      end

      def track_page(page_name, page_type)
        "dataLayer.push({ 'page_pageName': '#{page_name}', 'page_pageType': '#{page_type}'});"
      end

      def track(*args)
        name = args.first;
        "dataLayer.push({ 'page_virtualName': \"#{name}\", 'event': 'gtm.view' });"
      end

      def event(name, *args)
        params = args.first || {}
        <<-HTML
        var dataLayerEventData = #{params.to_json};
        dataLayerEventData['event'] = "#{name}";
        dataLayer.push(dataLayerEventData);
        HTML
      end

      def identify(name, *args)
        params = args.first || {}
        <<-HTML
        var dataLayerEventData = #{params.to_json};
        dataLayerEventData['event'] = 'identify';
        dataLayerEventData['user_id'] = "#{name}";
        dataLayer.push(dataLayerEventData);
        HTML
      end

      def set(data)
        return '' if data.blank?
        "dataLayer.push(#{data.to_json});"
      end

      def associate_lead(email, sha1)
        "dataLayer.push({ 'event': 'associateLead', 'leadEmail': '#{email}', 'authKey': '#{sha1}' });"
      end

    end
  end
end
