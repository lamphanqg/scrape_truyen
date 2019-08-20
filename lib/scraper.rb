# frozen_string_literal: true

class Scraper
  require "fileutils"
  require_relative "chapter"

  TEMPLATE = File.read("#{Dir.pwd}/page_template.html")

  def initialize(init_link, template_path, truyen_path, truyen_name)
    @init_link = init_link
    @truyen_path = truyen_path
    @truyen_name = truyen_name
  end

  def perform
    first_chapter = Chapter.new(@init_link)
    truyen_title = first_chapter.truyen_title

    last = false
    chapter_numbers = []
    link = @init_link
    while !last
      chapter = Chapter.new(link)
      number = chapter.number
      chapter_numbers << number
      process_one_chapter(chapter)

      next_chap_link = chapter.next_chap_link
      if next_chap_link.empty?
        last = true
        break
      end
      link = next_chap_link
    end

    generate_index(chapter_numbers, truyen_title)
    puts "DONE!"
  end

  private
    def generate_index(chapter_numbers, truyen_title)
      chapter_numbers.each_slice(50) do |chapter_group|
        generate_one_index(chapter_group, truyen_title)
      end
    end

    def generate_one_index(chapter_group, truyen_title)
      puts "Grouping chapters #{chapter_group.first} to #{chapter_group.last}"
      group_title = "#{@truyen_name}_#{chapter_group.first}_#{chapter_group.last}"
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

    def process_one_chapter(chapter)
      number = chapter.number
      title = chapter.title
      content = chapter.content
      puts "Process chapter #{number}"

      file_name = "#{@truyen_path}/#{number}.html"
      File.open(file_name, "w") do |f|
        fstring = TEMPLATE.gsub("{content}", content)
                          .gsub("{h1}", title)
        f.write(fstring)
      end
    end
end
