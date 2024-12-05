require "httparty"
require "nokogiri"

class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: [ :show, :edit, :update, :destroy, :refresh_investment_prices ]
  before_action :set_portfolios, only: [ :index, :create, :destroy ]

  def index
  end

  def show
    @investments = @portfolio.investments.includes(:transactions).order(:name)
    @notes = @portfolio.notes.order(importance: :asc, created_at: :desc)
  end

  def new
    @portfolio = Current.user.portfolios.build
  end

  def create
    @portfolio = Current.user.portfolios.build(portfolio_params)

    if @portfolio.save
      respond_to do |format|
        format.html { redirect_to @portfolio, notice: "Portfolio was successfully created." }
        format.turbo_stream {
          render_create_destroy_turbo_stream("Portfolio was successfully created.")
        }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @portfolio.update(portfolio_params)
      respond_to do |format|
        format.html { redirect_to @portfolio, notice: "Portfolio was successfully updated." }
        format.turbo_stream {
          render turbo_stream: [
            close_modal_turbo_stream,
            flash_turbo_stream_message("notice", "Portfolio was successfully updated."),
            turbo_stream.replace("portfolio_#{@portfolio.id}",
              partial: "portfolios/portfolio_header_tag",
              locals: { portfolio: @portfolio }
            )
          ]
        }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @portfolio.destroy
    respond_to do |format|
      format.turbo_stream {
        render_create_destroy_turbo_stream("Portfolio was successfully deleted.")
      }
    end
  end

  def refresh_investment_prices
    @portfolio.investments.each do |investment|
      begin
        # Simulate API call to get current price
        if investment.symbol.blank?
          investment.symbol = "GC=F" if investment.name.upcase == "GOLD"
          investment.symbol = "SI=F" if investment.name.upcase == "Silver"
          investment.symbol = "BTC-USD" if investment.name.upcase == "Bitcoin"
          investment.symbol = "ETH-USD" if investment.name.upcase == "Ethereum"
        end
        if investment.symbol.present?
          response = fetch_current_price(investment.symbol.upcase)
          investment.update(current_unit_price: response[:price], current_price_change: response[:change_amount], current_price_change_percent: response[:change_percent])
        end
      rescue => e
        Rails.logger.error "Failed to update price for #{investment.symbol}: #{e.message}"
      end
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("investments_table",
            partial: "investments_table",
            locals: { portfolio: @portfolio, investments: @portfolio.investments.order(:name) }
          ),
          turbo_stream.replace("portfolio_performance",
            partial: "portfolio_performance",
            locals: { portfolio: @portfolio }
          ),
          turbo_stream.replace("analytics",
            partial: "analytics",
            locals: { portfolio: @portfolio }
          ),
          flash_turbo_stream_message("notice", "Investment prices have been refreshed.")
        ]
      }
    end
  end

  private

    def render_create_destroy_turbo_stream(message)
      render turbo_stream: [
        close_modal_turbo_stream,
        flash_turbo_stream_message("notice", message),
        turbo_stream.replace("portfolios",
          partial: "portfolios/portfolios",
          locals: { portfolios: @portfolios }
        ),
        turbo_stream.replace("portfolio_select",
          partial: "shared/portfolio_select",
        )
      ]
    end


    def set_portfolios
      @portfolios = Current.user.portfolios.includes(:investments)
    end

    def set_portfolio
      @portfolio = Current.user.portfolios.find(params[:id])
    end

    def portfolio_params
      params.require(:portfolio).permit(:name)
    end

    def fetch_current_price(symbol)
      url = "https://finance.yahoo.com/quote/#{symbol}/"

      Rails.logger.info "Refresh price url: #{url}"

      response = HTTParty.get(url)
      doc = Nokogiri::HTML(response.body)

      price_nodes = doc.css("fin-streamer.livePrice span")
      price = price_nodes.any? && price_nodes.first.text.present? ? price_nodes.first.text.gsub(",", "") : nil

      change_amount_nodes = doc.css("fin-streamer.priceChange span")

      # price is first followed by percent change
      change_amount = change_amount_nodes.any? && change_amount_nodes.first..present? ? change_amount_nodes.first.text : nil
      change_percent = change_amount_nodes.any? && change_amount_nodes.last.text.present? ? change_amount_nodes.last.text : nil

      data ={ price: price, change_amount: change_amount, change_percent: change_percent } if price.present?

      Rails.logger.info "Refresh price data: #{data.inspect}"

      return data if price.present?

      raise "unable to fetch price for #{symbol}"
    rescue => e
      raise "Failed to fetch price: #{e.message}"
    end
end
