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
      set_notable
      respond_to do |format|
        format.turbo_stream {
          render_turbo_stream("Note was successfully created.")
        }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @note.update(note_params)
      set_notable
      respond_to do |format|
        format.turbo_stream {
          render_turbo_stream("Note was successfully updated.")
        }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    set_notable
    respond_to do |format|
      format.html { redirect_to polymorphic_path([ @portfolio, @notable ]), notice: "Note was successfully deleted." }
      format.turbo_stream {
        render_turbo_stream("Note was successfully deleted.")
      }
    end
  end

  private

    def render_turbo_stream(message)
      set_notable
      # Should be "portfolios" or "investments"
      path_prefix = @notable.class.name.downcase.pluralize
      render turbo_stream: [
        close_modal_turbo_stream,
        flash_turbo_stream_message("notice", message),
        turbo_stream.replace("notes-section",
          partial: "#{path_prefix}/notes_section",
          locals: { portfolio: params[:portfolio_id], investment: params[:investment_id], notes: @notes }
        )
      ]
    end

    def set_notable
      if params[:investment_id].present?
        @portfolio = Current.user.portfolios.find(params[:portfolio_id])
        @notable = @portfolio.investments.find(params[:investment_id])
      elsif params[:portfolio_id].present?
        @notable = Current.user.portfolios.find(params[:portfolio_id])
      end

      @notes = @notable.notes
    end

    def set_note
      @note = @notable.notes.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:content, :importance)
    end
end
