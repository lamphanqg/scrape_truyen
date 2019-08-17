# frozen_string_literal: true

class Scraper
  require "faraday"
  require "nokogiri"
  require "fileutils"

  TEMPLATE = File.read("#{Dir.pwd}/page_template.html")

  def initialize(init_link, template_path, truyen_path)
    @init_link = init_link
    @truyen_path = truyen_path
  end

  def perform
    first_page = get_parsed_response(@init_link)
    truyen_title_node = first_page.at_css("a.truyen-title")
    truyen_title = truyen_title_node["title"]

    last = false
    chapter_numbers = []
    link = @init_link
    while !last
      chapter_number = link.scan(/\d/).join
      chapter_numbers << chapter_number
      page = get_parsed_response(link)
      chapter_title_node = page.at_css(".chapter-title")
      chapter_title = chapter_title_node["title"]
      content_node = page.at_css(".chapter-c")
      content = content_node.inner_html

      file_name = "#{@truyen_path}/#{chapter_number}.html"
      File.open(file_name, "w") do |f|
        fstring = TEMPLATE.gsub("{content}", content)
                           .gsub("{h1}", chapter_title)
        f.write(fstring)
      end

      next_chap_link = get_next_chap(page)
      if next_chap_link.empty?
        last = true
        break
      end
      link = next_chap_link
    end

    generate_index(chapter_numbers, truyen_title)
  end

  private
    def generate_index(chapter_numbers, truyen_title)
      chapter_numbers.each_slice(50) do |chapter_group|
        generate_one_index(chapter_group, truyen_title)
      end
    end

    def generate_one_index(chapter_group, truyen_title)
      group_title = "#{truyen_title}_#{chapter_group.first}_#{chapter_group.last}"
      group_index_path = "#{@truyen_path}/#{group_title}.html"
      group_folder_path = "#{@truyen_path}/#{chapter_group.first}_#{chapter_group.last}"
      Dir.mkdir(group_folder_path)

      links = chapter_group.map do |chapter|
        "<li><a href='#{chapter}.html'>#{chapter}</a></li>"
      end

      File.open(group_index_path, "w") do |f|
        fstring = TEMPLATE.gsub("{content}", "<ul>\n#{links.join("\n")}\n</ul>")
                          .gsub("{h1}", truyen_title)
        f.write(fstring)
      end

      FileUtils.mv(group_index_path, group_folder_path)
      chapter_group.each do |chap|
        file = "#{@truyen_path}/#{chap}.html"
        FileUtils.mv(file, group_folder_path)
      end
    end

    def get_parsed_response(link)
      res = get_response(link)
      Nokogiri::HTML(res.body)
    end

    def get_response(link)
      Faraday.get(link)
    end

    def get_next_chap(page)
      next_chap_node = page.at_css("#next_chap")
      return "" if next_chap_node["class"].include?("disabled")
      next_chap_node["href"]
    end
end
