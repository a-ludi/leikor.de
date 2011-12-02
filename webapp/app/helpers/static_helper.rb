# Methods added to this helper will be available to all templates in the application.
module StaticHelper
  def static_link_to(path)
    if StaticController::REGISTERED_PAGES[path]
      link_to StaticController::REGISTERED_PAGES[path][:name], static_path(path)
    else
      raise ActionController::RoutingError, "static_link_to failed to generate from <#{path.inspect}> expected one of <#{StaticController::REGISTERED_PAGES.keys.inspect}>"
    end
  end
end
