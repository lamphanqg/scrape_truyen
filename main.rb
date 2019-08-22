# frozen_string_literal: true

require_relative("lib/scraper")

puts "Please input the first chapter's link"
init_link = STDIN.gets.chomp
puts "Please input a folder name"
truyen_name = STDIN.gets.chomp
template_path = "#{Dir.pwd}/page_template.html"
truyen_path = "#{Dir.pwd}/truyen/#{truyen_name}"
Dir.mkdir(truyen_path)
scraper = Scraper.new(init_link, template_path, truyen_path, truyen_name)
scraper.perform
