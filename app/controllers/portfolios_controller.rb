class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: [ :show, :edit, :update, :destroy ]
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
          replace_create_destroy_turbo_stream("Portfolio was successfully created.")
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
            turbo_stream.prepend("content", partial: "shared/flash", locals: { flash: [ [ "notice", "Potfolio was successfully updated." ] ] }),
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
    respond_to do |format|
      format.turbo_stream {
        replace_create_destroy_turbo_stream("Portfolio was successfully deleted.")
      }
    end
  end

  private

    def replace_create_destroy_turbo_stream(message)
      render turbo_stream: [
        turbo_stream.prepend("content", partial: "shared/flash", locals: { flash: [ [ "notice", message ] ] }),
        turbo_stream.update("modal", ""),
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
end
