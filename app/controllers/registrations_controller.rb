

class RegistrationsController < ::Milia::RegistrationsController

    skip_before_action :authenticate_tenant!, :only => [:new, :create, :cancel]
    
    def create
        # have a working copy of the params in case Tenant callbacks
        # make any changes
      tenant_params = sign_up_params_tenant
      # this creates the first user who creates the tenant, only way to be admin
      user_params   = sign_up_params_user.merge({ is_admin: true })
      coupon_params = sign_up_params_coupon
    
      sign_out_session!
         # next two lines prep signup view parameters
      prep_signup_view( tenant_params, user_params, coupon_params )
    
         # validate recaptcha first unless not enabled
      if !::Milia.use_recaptcha  ||  verify_recaptcha
    
        Tenant.transaction  do
          @tenant = Tenant.create_new_tenant( tenant_params, user_params, coupon_params)
          if @tenant.errors.empty?   # tenant created
            if @tenant.plan == 'premium' #check for preumiu, else don't bother
                @payment = Payment.new({email: user_params["email"],
                                        token: params[:payment]["token"],
                                        tenant: @tenant })
                flash[:error] = "Please check registration errors." unless @payment.valid?
            
                begin
                    @payment.process_payment
                    @payment.save
                rescue Exception => e 
                    flash[:error] = e.message
                    @tenant.destroy 
                    log_action("Payment failed.")
                    render :new and return 
                end
            end
            
          else  # tenant errors was not empty (had err0r)
            resource.valid?
            log_action( "tenant create failed", @tenant )
            render :new  and return
          end # if .. then .. else no tenant errors
          
          if flash[:error].blank? || flash[:error].empty? #payment succesfful
            initiate_tenant( @tenant )    # first time stuff for new tenant
            devise_create( user_params )   # devise resource(user) creation; sets resource
            if resource.errors.empty?   #  SUCCESS!
              log_action( "signup user/tenant success", resource )
                # do any needed tenant initial setup
              Tenant.tenant_signup(resource, @tenant, coupon_params)
            else  # user creation failed; force tenant rollback
              log_action( "signup user create failed", resource )
              raise ActiveRecord::Rollback   # force the tenant transaction to be rolled back
            end  # if..then..else for valid user creation
          else #some kind of payment failure 
              resource.valid?
              log_action("Payment processing failed.", @tenant)
              render :new and return
          end # if no tenant errors
        end  #  wrap tenant/user creation in a transaction
      else # forked from the milia line 19
        flash[:error] = "Recaptcha codes didn't match; please try again"
           # all validation errors are passed when the sign_up form is re-rendered
        resource.valid?
        @tenant.valid?
        log_action( "recaptcha failed", resource )
        render :new  and return
      end
    
    end   # def create
    
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
    
  protected
    
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
      def sign_up_params_tenant()
        params.require(:tenant).permit( ::Milia.whitelist_tenant_params )
      end
    
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
      def sign_up_params_user()
        devise_parameter_sanitizer.sanitize(:sign_up)
      end
    
    # ------------------------------------------------------------------------------
    # sign_up_params_coupon -- permit coupon parameter if used; else params
    # ------------------------------------------------------------------------------
      def sign_up_params_coupon()
        ( ::Milia.use_coupon ?
          params.require(:coupon).permit( ::Milia.whitelist_coupon_params )  :
          params
        )
      end
    
    # ------------------------------------------------------------------------------
    # sign_out_session! -- force the devise session signout
    # ------------------------------------------------------------------------------
      def sign_out_session!()
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name) if user_signed_in?
      end
    
    # ------------------------------------------------------------------------------
    # devise_create -- duplicate of Devise::RegistrationsController
        # same as in devise gem EXCEPT need to prep signup form variables
    # ------------------------------------------------------------------------------
      def devise_create( user_params )
        build_resource(user_params)
    
        # if we're using milia's invite_member helpers
        if ::Milia.use_invite_member
          # then flag for our confirmable that we won't need to set up a password
          resource.skip_confirm_change_password  = true
        end
    
        resource.save
        yield resource if block_given?
        log_action( "devise: signup user success", resource )
    
        if resource.persisted?
          if resource.active_for_authentication?
            set_flash_message :notice, :signed_up
            sign_up(resource_name, resource)
            respond_with resource, location: after_sign_up_path_for(resource)
          else
            set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
            expire_data_after_sign_in!
            respond_with resource, location: after_inactive_sign_up_path_for(resource)
          end
        else
          # re-show signup view
          clean_up_passwords resource
          log_action( "devise: signup user failure", resource )
          set_minimum_password_length
          prep_signup_view(  @tenant, resource, params[:coupon] )
          respond_with resource
        end
      end
    
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
      def after_sign_up_path_for(resource)
        headers['refresh'] = "0;url=#{root_path}"
        root_path
      end
    
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
      def after_inactive_sign_up_path_for(resource)
        headers['refresh'] = "0;url=#{root_path}"
        root_path
      end
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
    
      def log_action( action, resource=nil )
        err_msg = ( resource.nil? ? '' : resource.errors.full_messages.uniq.join(", ") )
        logger.debug(
          "MILIA >>>>> [register user/org] #{action} - #{err_msg}"
        ) unless logger.nil?
      end
    
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------
    
    # ------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------

end   # class Registrations