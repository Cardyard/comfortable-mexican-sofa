# frozen_string_literal: true

class Comfy::Cms::BaseController < ComfortableMexicanSofa.config.public_base_controller.to_s.constantize

  before_action :load_cms_site

  helper Comfy::CmsHelper

protected

  def load_cms_site
    # This controller is inherited by following controllers, which call
    #   this method since it is referenced in "before action" above
    #     Comfy::Cms::ContentController
    #     Comfy::Cms::AssetsController
    @cms_site ||=
      if params[:site_id]
        ::Comfy::Cms::Site.find_by_id(params[:site_id])
      else
        ::Comfy::Cms::Site.find_site(request.host_with_port.downcase, request.fullpath)
      end

    if @cms_site
      if @cms_site.path.present? && !params[:site_id]
        if params[:cms_path]&.match(%r{\A#{@cms_site.path}})
          params[:cms_path].gsub!(%r{\A#{@cms_site.path}}, "")
          params[:cms_path]&.gsub!(%r{\A/}, "")
        else
          # Following "raise" doesn't appear to work in Rails 8, so use
          #   scope variable
          # raise ActionController::RoutingError, "Site Not Found"
          @routing_error = true
        end
      end
    else
      # raise ActionController::RoutingError, "Site Not Found"
      @routing_error = true
    end
  end

end
