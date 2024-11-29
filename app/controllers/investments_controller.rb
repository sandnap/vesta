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
      redirect_to portfolio_path(@portfolio), notice: "Investment was successfully created."
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
          render turbo_stream: [
            turbo_stream.prepend("content", partial: "shared/flash", locals: { flash: [ [ "notice", "Investment was successfully updated." ] ] }),
            turbo_stream.update("modal", ""),
            turbo_stream.replace("investments_table",
              partial: "portfolios/investments_table",
              locals: { portfolio: @portfolio, investments: @portfolio.investments.order(:name) }
            )
          ]
        }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @investment.destroy
    redirect_to portfolio_path(@portfolio), notice: "Investment was successfully deleted."
  end

  private

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
