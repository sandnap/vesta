class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: [ :show, :edit, :update, :destroy ]

  def index
    @portfolios = Current.user.portfolios.includes(:investments)
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
      redirect_to @portfolio, notice: "Portfolio was successfully created."
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
            turbo_stream.update("modal", ""),
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
    redirect_to portfolios_url, notice: "Portfolio was successfully deleted."
  end

  private

  def set_portfolio
    @portfolio = Current.user.portfolios.find(params[:id])
  end

  def portfolio_params
    params.require(:portfolio).permit(:name)
  end
end
