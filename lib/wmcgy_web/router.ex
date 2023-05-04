defmodule WmcgyWeb.Router do
  use WmcgyWeb, :router

  import WmcgyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WmcgyWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" => "default-src 'self';img-src data: w3.org/svg/200 'self'"
    }

    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WmcgyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", LandingPageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", WmcgyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:wmcgy, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: WmcgyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", WmcgyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{WmcgyWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", WmcgyWeb do
    pipe_through [:browser, :require_authenticated_user]

    post "/transactions/export", TransactionExportController, :create

    live_session :require_authenticated_user,
      on_mount: [
        {WmcgyWeb.UserAuth, :ensure_authenticated},
        {WmcgyWeb.InjectWallDate, :assign_local_wall_date}
      ] do
      # Transactions routes
      live "/transactions", TransactionLive.Index, :index
      live "/transactions/new", TransactionLive.New, :new
      live "/transactions/:id/edit", TransactionLive.Edit, :edit
      live "/transactions/import", TransactionLive.Import, :import

      # Categories routes
      live "/categories", CategoryLive.Index, :index
      live "/categories/new", CategoryLive.Index, :new
      live "/categories/:id/edit", CategoryLive.Index, :edit

      # Report routes
      live "/reports", ReportLive.Index, :index

      # Account routes
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", WmcgyWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{WmcgyWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
