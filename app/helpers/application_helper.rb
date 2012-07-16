module ApplicationHelper

  # Returns page title
  def full_title(page_title)
    base_title = "matkam.net"

    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end

  end

end
