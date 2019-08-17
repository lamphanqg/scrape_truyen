# frozen_string_literal: true

require_relative("scraper")

init_link = "https://truyenfull.vn/that-tich-khong-mua/chuong-1/"
template_path = "#{Dir.pwd}/page_template.html"
truyen_path = "#{Dir.pwd}/truyen/that_tich_khong_mua"
Dir.mkdir(truyen_path)
scraper = Scraper.new(init_link, template_path, truyen_path)
scraper.perform
