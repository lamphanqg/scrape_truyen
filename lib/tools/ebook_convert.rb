# Warning: Don't forget to add Calibre CLI tools into
# $PATH of your system
module EbookConvert
  require "open3"
  def self.html_to_mobi(input_file, output_file)
    cmd = "ebook-convert #{input_file} #{output_file}"
    puts "Converting #{input_file}\n        to #{output_file}"
    output, error, status = Open3.capture3(cmd)
    if status.success?
      puts "Conversion done"
    else
      puts "Conversion failed with error: #{error}"
    end
  end
end
