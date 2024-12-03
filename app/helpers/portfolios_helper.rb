module PortfoliosHelper
  def note_importance_class(note)
    if note.importance == 1
      "text-red-800 bg-red-100 dark:bg-red-900 dark:text-red-300"
    elsif note.importance <= 3
      "text-yellow-800 bg-yellow-100 dark:bg-yellow-900 dark:text-yellow-300"
    else
      "text-blue-800 bg-blue-100 dark:bg-blue-900 dark:text-blue-300"
    end
  end

  def total_return_color_class(value)
    if value.positive?
      "text-green-500 dark:text-green-400"
    elsif value.negative?
      "text-red-500 dark:text-red-400"
    else
      "text-gray-900 dark:text-white"
    end
  end
end
