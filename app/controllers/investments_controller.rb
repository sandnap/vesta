class InvestmentsController < ApplicationController
  before_action :set_portfolio
  before_action :set_investment, except: [ :new, :create ]

  def show
    @transactions = @investment.transactions.order(transaction_date: :desc)
    @notes = @investment.notes.order(importance: :asc, created_at: :desc)
  end

  def new
    @investment = @portfolio.investments.build
  end

  def create
    @investment = @portfolio.investments.build(investment_params)

    if @investment.save
      respond_to do |format|
        format.html { redirect_to portfolio_path(@portfolio), notice: "Investment was successfully created." }
        format.turbo_stream {
          render_turbo_stream("Investment was successfully created.")
        }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @investment.update(investment_params)
      respond_to do |format|
        format.html { redirect_to portfolio_path(@portfolio), notice: "Investment was successfully updated." }
        format.turbo_stream {
          render_turbo_stream("Investment was successfully updated.")
        }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @investment.destroy
    respond_to do |format|
      format.html { redirect_to portfolio_path(@portfolio), notice: "Investment was successfully deleted." }
      format.turbo_stream {
        render_turbo_stream("Investment was successfully deleted.")
      }
    end
  end

  private

    def render_turbo_stream(message)
      render turbo_stream: [
        close_modal_turbo_stream,
        flash_turbo_stream_message("notice", message),
        turbo_stream.replace("investments_table",
          partial: "portfolios/investments_table",
          locals: { portfolio: @portfolio, investments: @portfolio.investments.order(:name) }
        ),
        turbo_stream.replace("analytics",
          partial: "portfolios/analytics",
          locals: { portfolio: @portfolio }
        )
      ]
    end

    def set_portfolio
      @portfolio = Current.user.portfolios.find(params[:portfolio_id])
    end

    def set_investment
      @investment = @portfolio.investments.find(params[:id])
    end

    def investment_params
      params.require(:investment).permit(:name, :symbol, :investment_type, :status, :current_unit_price, :exit_target_type)
    end
end
