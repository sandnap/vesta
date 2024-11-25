class InvestmentsController < ApplicationController
  before_action :set_portfolio
  before_action :set_investment, only: [ :show, :edit, :update, :destroy ]

  def index
    @investments = @portfolio.investments.includes(:transactions)
  end

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
      redirect_to portfolio_investment_path(@portfolio, @investment), notice: "Investment was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @investment.update(investment_params)
      redirect_to portfolio_investment_path(@portfolio, @investment), notice: "Investment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @investment.destroy
    redirect_to portfolio_investments_url(@portfolio), notice: "Investment was successfully deleted."
  end

  private

  def set_portfolio
    @portfolio = Current.user.portfolios.find(params[:portfolio_id])
  end

  def set_investment
    @investment = @portfolio.investments.find(params[:id])
  end

  def investment_params
    params.require(:investment).permit(:name, :symbol, :exit_target_type, :current_unit_price)
  end
end
