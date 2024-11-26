class TransactionsController < ApplicationController
  before_action :set_portfolio
  before_action :set_investment, except: [ :new, :create ]
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
    @transaction = if params[:investment_id]
      @investment = @portfolio.investments.find(params[:investment_id])
      @investment.transactions.build
    else
      Transaction.new
    end
  end

  def create
    @transaction = if params[:investment_id]
      @investment = @portfolio.investments.find(params[:investment_id])
      @investment.transactions.build(transaction_params)
      respond_to do |format|
        format.html { redirect_to portfolio_investment_path(@portfolio, @investment), notice: "Transaction was successfully created." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.replace("transactions_table",
              partial: "transactions/transactions",
              locals: { portfolio: @portfolio, investment: @investment, transactions: @investment.transactions }
            )
          ]
        end
      end
    else
      @investment = @portfolio.investments.find(transaction_params[:investment_id])
      @investment.transactions.build(transaction_params)
    end

    if @transaction.save
      redirect_to params[:investment_id] ? portfolio_investment_path(@portfolio, @investment) : portfolio_path(@portfolio),
                  notice: "Transaction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      respond_to do |format|
        format.html { redirect_to portfolio_investment_path(@portfolio, @investment), notice: "Transaction was successfully updated." }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.replace("transactions_table",
              partial: "investments/transactions",
              locals: { portfolio: @portfolio, investment: @investment, transactions: @investment.transactions }
            )
          ]
        end
      end
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
    params.require(:transaction).permit(:transaction_date, :transaction_type, :units, :unit_price, :investment_id)
  end
end
