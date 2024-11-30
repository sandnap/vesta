class NoteDraftsController < ApplicationController
  before_action :set_notable
  before_action :set_note_draft, only: [ :show, :update, :destroy ]

  def show
    respond_to do |format|
      format.json { render json: @note_draft }
    end
  end

  def create
    @note_draft = Current.user.note_drafts.build(note_draft_params.merge(notable: @notable))

    respond_to do |format|
      if @note_draft.save
        format.json { render json: @note_draft, status: :created }
      else
        format.json { render json: @note_draft.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @note_draft.update(note_draft_params)
        format.json { render json: @note_draft }
      else
        format.json { render json: @note_draft.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @note_draft.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

    def set_notable
      if params[:investment_id].present?
        portfolio = Current.user.portfolios.find(params[:portfolio_id])
        @notable = portfolio.investments.find(params[:investment_id])
      elsif params[:portfolio_id].present?
        @notable = Current.user.portfolios.find(params[:portfolio_id])
      end
    end

    def set_note_draft
      @note_draft = Current.user.note_drafts.find_by!(notable: @notable)
    end

    def note_draft_params
      params.require(:note_draft).permit(:content, :importance)
    end
end
