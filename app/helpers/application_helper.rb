module ApplicationHelper

  def is_active?(controller, action='')
    "active" if params[:controller].match(controller) and params[:action].match(action)
  end

  def title(page_title)
    content_for (:title) { page_title + " / LdapControl" }
  end

  def yield_or_default(section, default = "LdapControl")
    content_for?(section) ? content_for(section) : default
  end


  def flash_class(level)
    case level
      when 'notice' then "alert-box info radius"
      when 'success' then "alert-box success radius"
      when 'error' then "alert-box warning radius"
      when 'alert' then "alert-box alert radius"
      else
        "alert-box info radius"
    end
  end

  def field_class(resource, field_name)
    if resource.errors[field_name]
      "error".html_safe
    else
      "".html_safe
    end
  end

  def field_error_message(resource, field_name)
    if resource.errors[field_name] and !resource.errors[field_name].blank?
      error_message = '<small class="error">'
      resource.errors[field_name].each do |error|
        error_message += "#{error}, "
      end
      error_message.chop!.chop!
      error_message += "</small>"
      error_message.html_safe
    else
      "".html_safe
    end
  end


end
