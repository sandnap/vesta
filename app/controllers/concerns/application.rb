module Application
  extend ActiveSupport::Concern

  def flash_turbo_stream_message(type, message)
    turbo_stream.prepend("content", partial: "shared/flash", locals: { flash: [ [ type, message ] ] })
    # turbo_stream.replace("flash-messages", partial: "shared/flash", locals: { flash: [ [ type, message ] ] })
  end

  def close_modal_turbo_stream
    turbo_stream.update("modal", "")
  end
end
