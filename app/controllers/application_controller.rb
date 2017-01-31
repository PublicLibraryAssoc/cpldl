class ApplicationController < ActionController::Base
  before_action :current_organization
  before_action :set_locale
  before_action :set_language
  before_action :set_cms_footer_pages
  before_action :set_user_token
  before_action :set_mailer_host
  before_action :require_valid_profile
  protect_from_forgery with: :exception

  helper_method :current_organization
  helper_method :subdomain?
  helper_method :top_level_domain?

  layout proc { user_signed_in? || !subdomain? ? "user/logged_in" : "application" }

  def current_organization
    if staging?
      Organization.find_by_subdomain(stage_subdomain) || Organization.find_by_subdomain("www")
    elsif request.subdomain == "" || request.subdomain == "admin"
      Organization.find_by_subdomain("") || Organization.find_by_subdomain("www")
    else
      Organization.find_by_subdomain(request.subdomain) || Organization.find_by_subdomain("www")
    end
  end

  def set_mailer_host
    if staging?
      ActionMailer::Base.default_url_options[:host] = "#{stage_subdomain}.stage.digitallearn.org"
    elsif Rails.env.production?
      ActionMailer::Base.default_url_options[:host] = "#{current_organization.subdomain}.digitallearn.org"
    else
      ActionMailer::Base.default_url_options[:host] = request.host
    end
  end

  def require_valid_profile
    if invalid_user_profile?
      flash[:alert] = "You must have a valid profile before you can continue:"
      redirect_to invalid_profile_path
    end
  end

  def staging?
    request.subdomain.include?("stage")
  end

  def stage_subdomain
    subdomain_array = request.subdomain.split(".")
    if subdomain_array.size == 2
      subdomain_array.first
    else
      "www"
    end
  end

  def base_url
    if request.host.include?("stage")
      "stage.digitallearn.org"
    else
      "digitallearn.org"
    end
  end

  def top_level_domain?
    current_organization.subdomain == "www"
  end

  def subdomain?
    !(current_organization.subdomain == "www" || current_organization.subdomain == "")
  end

  def after_sign_in_path_for(user)
    check_user_subdomain(user)
    if (user.is_super? || user.has_role?(:admin, current_organization)) and user.profile.nil?
      flash[:notice] = "This is the first time you have logged in, update your profile!"
      profile_path
    elsif user.has_role?(:admin, current_organization)
      admin_dashboard_index_path
    elsif !user.profile.valid?
      profile_path
    elsif first_time_login?
      flash[:notice] = "This is the first time you have logged in, update your profile!"
      profile_path
    else
      root_path
    end
  end

  def check_user_subdomain(user)
    if user.organization != current_organization
      user.update_attribute(:sign_in_count,  0) if user.sign_in_count == 1
      sign_out user
      user_subdomain = user.organization.subdomain
      flash[:alert] = %Q[Oops! You’re a member of #{user.organization.name}. Sign in at <a href="http://#{user_subdomain}.#{base_url}">#{user_subdomain}.#{base_url}</a>]
      root_path
    else
      root_path
    end
  end

  def set_language
    @language = Language.find_by(id: 1) unless Language.all.blank?
  end

  def set_cms_footer_pages
    english_id = Language.find_by_name("English").try(:id) || 1
    spanish_id = Language.find_by_name("Spanish").try(:id) || 2
    org_id = current_organization.id
    case I18n.locale
    when :es
      @footer_pages = CmsPage.where(pub_status: "P", language_id: spanish_id, organization_id: org_id)
    else
      @footer_pages = CmsPage.where(pub_status: "P", language_id: english_id, organization_id: org_id)
    end
  end

  def set_locale
    if current_user && current_user.profile && current_user.profile.language.blank? == false
      if user_language_override? == true
        I18n.locale = session[:locale].to_sym unless session[:locale].blank?
      else
        case current_user.profile.language.name
        when "English"
          I18n.locale = :en
        when "Spanish"
          I18n.locale = :es
        end
      end
    else
      I18n.locale = session[:locale].nil? ? :en : session[:locale].to_sym
    end
  end

  def first_time_login?
    current_user.present? && current_user.sign_in_count == 1 && current_user.profile.present? && current_user.profile.created_at.to_s == current_user.profile.updated_at.to_s
  end

  private

  def invalid_user_profile?
    current_user.present? && current_user.profile.present? && !current_user.profile.valid?
  end

  def user_language_override?
    if current_user.profile.language.blank? == false
      user_lang_abbrv2 = current_user.profile.language_id == 1 ? "en" : "es"
      return true if session[:locale] != user_lang_abbrv2
    else
      return false
    end
  end

  # TODO: determine if we need to set the client_ID or if we can use googles
  # def save_google_analytics_client_id
  #   if current_user && cookies["_ga"]
  #     client_id = cookies["_ga"].split(".").last(2).join(".")
  #     if current_user.google_analytics_client_id != client_id
  #       current_user.google_analytics_client_id = client_id
  #       current_user.save
  #     end
  #   end
  # end

  def set_user_token
    if current_user && current_user.token
      session[:user_ga_id] = current_user.token
    elsif current_user && current_user.token.blank?
      current_user.send(:add_token_to_user)
      current_user.save(validate: false)
      session[:user_ga_id] = current_user.token
    else
      session[:user_ga_id] = "guest"
    end
  end

end
