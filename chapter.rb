# frozen_string_literal: true

class Chapter
  require "faraday"
  require "nokogiri"

  def initialize(link)
    @link = link
    @page = get_parsed_response
  end

  def info
    number = get_number
    title = get_title
    content = get_content
    return number, title, content
  end

  def next_chap_link
    get_next_chap_link
  end

  def truyen_title
    get_truyen_title
  end

  private
    def get_content
      content_node = @page.at_css(".chapter-c")
      content_node.inner_html
    end

    def get_next_chap_link
      next_chap_node = @page.at_css("#next_chap")
      return "" if next_chap_node["class"].include?("disabled")
      next_chap_node["href"]
    end

    def get_number
      @link.scan(/\d/).join
    end

    def get_parsed_response
      res = get_response
      Nokogiri::HTML(res.body)
    end

    def get_response
      Faraday.get(@link)
    end

    def get_title
      title_node = @page.at_css(".chapter-title")
      title_node["title"]
    end

    def get_truyen_title
      truyen_title_node = @page.at_css("a.truyen-title")
      truyen_title_node["title"]
    end
end