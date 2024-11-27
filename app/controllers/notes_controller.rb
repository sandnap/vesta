class NotesController < ApplicationController
  before_action :set_notable
  before_action :set_note, only: [ :edit, :update, :destroy ]

  def new
    @note = if (draft = Current.user.note_drafts.find_by(notable: @notable))
      draft.to_note
    else
      @notable.notes.build
    end
  end

  def create
    @note = @notable.notes.build(note_params)

    if @note.save
      Current.user.note_drafts.find_by(notable: @notable)&.destroy
      redirect_to polymorphic_path([ @portfolio, @notable ]), notice: "Note was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to polymorphic_path([ @portfolio, @notable ]), notice: "Note was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to polymorphic_path([ @portfolio, @notable ]), notice: "Note was successfully deleted."
  end

  private

  def set_notable
    if params[:investment_id].present?
      @portfolio = Current.user.portfolios.find(params[:portfolio_id])
      @notable = @portfolio.investments.find(params[:investment_id])
    elsif params[:portfolio_id].present?
      @notable = Current.user.portfolios.find(params[:portfolio_id])
    end
  end

  def set_note
    @note = @notable.notes.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:content, :importance)
  end
end
