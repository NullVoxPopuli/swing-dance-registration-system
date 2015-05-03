module ApplicationHelper

  def small_datetime_select(form, field_name, label)
    form.label(field_name, label) +
    content_tag(:div, class: "row") do
      content_tag(:div, class: "small-6 columns") do
        form.label(field_name, "Date") +
        form.date_select(field_name, { required: true, include_blank: true }, { class: 'small-3' })
      end +
      content_tag(:div, class: "small-6 columns") do
        form.label(field_name, "Time") +
        form.time_select(field_name, { required: true, ignore_date: true , include_blank: true}, { class: 'small-3' })
      end
    end
  end

  def google_analytics_code
    %Q{
      <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', 'UA-58633414-1', 'auto');
        ga('send', 'pageview');
        ga('set', '&uid', '#{current_user ? current_user.id : ''}');

      </script>
    }.html_safe
  end

  def event_url_for(item, action: nil)
    url_objects = [:hosted, @event, item]
    url_objects << action if action.present?
    url_for(url_objects)
  end

  def public_url(event, path)
    "http://" + event.subdomain + '.' + current_domain + request.port_string + path
  end

  def nav_title

    if show_public_link?
      content_tag(:h1) {
        link_to current_event.name, public_registration_hosted_event_path(current_event, protocol: 'http')
      }
    elsif @event && @event.persisted?
      content_tag(:h1, style: "display: inline-block;") {
        link_to( @event.name, hosted_event_path(@event) )
      }+
        options_for(links: hosted_event_links)
    else
      content_tag(:h1) {
        link_to APPLICATION_CONFIG["app_name"], root_path
      }
    end
  end

  def show_public_link?
    event = (defined?(current_event) ? current_event : @event)
    event.present? && event.persisted? &&
      defined?(current_user) && current_user.present? &&
      !(current_user.hosted_event_ids.include?(event.id) || current_user.collaborated_event_ids.include?(event.id))
  end

  def options_for(links: {})
    @dropdowns ||= 0

    content_tag(:a, "data-dropdown" => "drop#{@dropdowns += 1}",
                href: "#",
                style: "line-height: 46px; color: white;"
    ){
      content_tag(:i, :class => "fa fa-ellipsis-v") {}
    } +
      content_tag(:ul,
                  id: "drop#{@dropdowns}",
                  :class => "medium f-dropdown left",
                  "data-dropdown-content" => "",
    "aria-hidden"=>"false") {
      if links.is_a?(Hash)
        options_from_hash(links).html_safe
      elsif links.is_a?(Array)
        options_from_array(links).html_safe
      end
    }
  end

  # hash should be:
  #  link_name => link_url
  def options_from_hash(hash)
    result = ""
    hash.each { |name, url|
      result += content_tag(:li) { link_to name, url }
    }
    return result
  end

  # array should be of hashes
  def options_from_array(array)
    array.map { | hash |
      options_from_hash(hash)
    }.join(content_tag(:li, class: "divider") {content_tag(:hr){}})
  end

  def hosted_event_links(event = @event)
    [
      {
        "At the Door" => hosted_event_sales_path(event),
        "Edit" => edit_hosted_event_path(event)
      },
      {
        "Competitions" => hosted_event_competitions_path(event),
        "Packages" => hosted_event_packages_path(event),
        "Levels" => hosted_event_levels_path(event),
        "Pricing Tier Tables" => pricing_tables_hosted_event_path(event),
        "Discounts" => hosted_event_discounts_path(event),
        "Passes" => hosted_event_passes_path(event)
      },
      {
        "Registrants" => hosted_event_path(event),
        "Public Registration" => public_registration_hosted_event_path(event)
      },
      {
        "Charts" => charts_hosted_event_path(event),
        "Revenue Summary" => revenue_hosted_event_path(event)
      }
    ]
  end

  def dropdown_options(links: [], options: {})
    @dropdowns ||= 0

    align = options[:align] || "right"

    content_tag(:a, "data-dropdown" => "drop#{@dropdowns +=1 }", href: "#", class: "#{align}") {
      content_tag(:i, class: "fa fa-ellipsis-v") {}
    } +
    content_tag(:ul, id: "drop#{@dropdowns}", class: "f-dropdown", "data-dropdown-content" => "") {
      links.map do |link|
        content_tag(:li) {
          link_to( link[:name], link[:path], link[:options] )
        }
      end.join.html_safe
    }
  end

  # Tables are used everywhere, and are pretty much all rendered
  # the same.
  #
  # collection: [], columns: []
  def item_table(args)
    render(partial: '/shared/item_table', locals: args)
  end

  def tooltip_tag(msg)
    content_tag(:span,
      "data-tooltip" => "",
      "data-width" => "200",
      class: "has-tip",
      title: msg
    ){
      tag("i", class: "fa fa-info-circle")
    }
  end

end