defmodule Wmcgy.Mailer do
  use Swoosh.Mailer, otp_app: :wmcgy

  defmacro __using__(_opts) do
    quote do
      import Swoosh.Email
      import Phoenix.Component

      @spec body(Swoosh.Email.t(), Phoenix.LiveView.Rendered.t()) :: Swoosh.Email.t()
      def body(email, mjml) do
        {:ok, html_body} =
          layout(%{inner_content: mjml})
          |> Phoenix.HTML.Safe.to_iodata()
          |> IO.chardata_to_string()
          |> Mjml.to_html()

        text_body = html_body |> Premailex.to_text()

        email
        |> html_body(html_body)
        |> text_body(text_body)
      end

      def button(var!(assigns)) do
        ~H"""
        <mj-button
          background-color="#047857"
          color="#FFFFFF"
          href={@url}
          font-family="Arial, sans-serif"
          font-weight="bold"
          font-size="16px"
        >
          <%= render_slot(@inner_block) %>
        </mj-button>
        """
      end

      def header(var!(assigns)) do
        ~H"""
        <mj-text align="center" color="#57534E" font-size="24px" font-weight="bold" padding-bottom="30px">
          <%= render_slot(@inner_block) %>
        </mj-text>
        """
      end

      def text(var!(assigns)) do
        ~H"""
        <mj-text align="left" color="#57534E" font-size="16px" padding-top="5px">
          <%= render_slot(@inner_block) %>
        </mj-text>
        """
      end

      defp layout(var!(assigns)) do
        ~H"""
        <mjml>
          <mj-head>
            <mj-font name="Lobster" href="https://fonts.googleapis.com/css?family=Lobster" />
            <mj-attributes>
              <mj-class name="green-background" background-color="#047857" />
              <mj-class
                name="logo"
                font-size="72px"
                font-family="Lobster"
                color="#FFF"
                line-height="48px"
                align="center"
              />
              <mj-class
                name="footer"
                font-size="13px"
                font-family="Arial, sans-serif"
                color="#FFF"
                font-weight="bold"
                align="center"
              />
              <mj-button
                background-color="#5666F6"
                font-size="14px"
                color="#ffffff"
                font-family="Open Sans"
                text-transform="capitalize"
                height="45px"
                width="200px"
              />
            </mj-attributes>
          </mj-head>
          <mj-body background-color="#E7E5E4">
            <!-- header section -->
            <mj-section mj-class="green-background">
              <mj-column>
                <mj-text mj-class="logo">Wmcgy</mj-text>
              </mj-column>
            </mj-section>
            <!-- main content -->
            <mj-section background-color="#FFFFFF" padding-bottom="20px" padding-top="20px">
              <mj-column vertical-align="top" width="100%">
                <%= @inner_content %>
              </mj-column>
            </mj-section>
            <!-- footer section -->
            <mj-section mj-class="green-background">
              <mj-text mj-class="footer">
                &copy; <%= Date.utc_today().year %> Where Did My Cash Go Yo
              </mj-text>
            </mj-section>
            <!-- secondary footer -->
            <mj-section>
              <mj-text></mj-text>
              <mj-text mj-class="footer-text" align="center" padding="0 10px">
                <p style="Margin:0; padding-bottom:10px; font-size:10px; line-height:15px; Margin-bottom:10px; color:#111111; font-family: 'Open Sans', 'Raleway', Arial, Helvetica, sans-serif;">
                  This message contains important information regarding your account registered at Where Did My Cash Go Yo associated with this email.
                  You may not opt out of account management emails sent by Where Did My Cash Go Yo. If you are not the intended recipient or have
                  received this email in error, please notify us immediately at info@wheredidmycashgoyo.com and delete this message.
                </p>
                <p style="Margin:0; padding-bottom:10px; font-size:10px; line-height:15px; Margin-bottom:10px; color:#111111; font-family: 'Open Sans', 'Raleway', Arial, Helvetica, sans-serif;">
                  We only send emails to individuals who have registered at our site:
                  <a
                    href="https://wheredidmycashgoyo.com/"
                    style="color:#111111; text-decoration:underline;"
                  >
                    www.wheredidmycashgoyo.com
                  </a>
                </p>
              </mj-text>
            </mj-section>
          </mj-body>
        </mjml>
        """
      end
    end
  end
end
