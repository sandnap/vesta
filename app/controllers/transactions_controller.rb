class TransactionsController < ApplicationController
  before_action :set_portfolio
  before_action :set_investment
  before_action :set_transaction, only: [ :edit, :update, :destroy ]

  def index
    @transactions = @investment.transactions.order(transaction_date: :desc)

    respond_to do |format|
      format.html
      format.csv { send_data @transactions.to_csv, filename: "#{@investment.name}-transactions-#{Date.current}.csv" }
      format.json { send_data @transactions.to_json_export, filename: "#{@investment.name}-transactions-#{Date.current}.json" }
    end
  end

  def new
    @transaction = @investment.transactions.build
  end

  def create
    @transaction = @investment.transactions.build(transaction_params)

    if @transaction.save
      redirect_to portfolio_investment_path(@portfolio, @investment),
                  notice: "Transaction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to portfolio_investment_path(@portfolio, @investment),
                  notice: "Transaction was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy
    redirect_to portfolio_investment_path(@portfolio, @investment),
                notice: "Transaction was successfully deleted."
  end

  def export
    start_date = params[:start_date].present? ? Time.zone.parse(params[:start_date]) : 30.days.ago.beginning_of_day
    @transactions = @investment.transactions.where("transaction_date >= ?", start_date).order(transaction_date: :desc)
    @date_range_options = Transaction.date_range_options

    respond_to do |format|
      format.html
      format.turbo_stream
      format.csv { send_data @transactions.to_csv, filename: "#{@investment.name}-transactions-#{start_date.to_date}-#{Date.current}.csv" }
      format.json { send_data @transactions.to_json_export, filename: "#{@investment.name}-transactions-#{start_date.to_date}-#{Date.current}.json" }
    end
  end

  private

  def set_portfolio
    @portfolio = Current.user.portfolios.find(params[:portfolio_id])
  end

  def set_investment
    @investment = @portfolio.investments.find(params[:investment_id])
  end

  def set_transaction
    @transaction = @investment.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:transaction_date, :transaction_type, :units, :unit_price)
  end
end
