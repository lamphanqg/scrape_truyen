# Warning: Don't forget to add Calibre CLI tools into
# $PATH of your system
module EbookConvert
  require "open3"
  def self.html_to_mobi(input_file, output_file)
    cmd = "ebook-convert #{input_file} #{output_file}"
    output, error, status = Open3.capture3(cmd)
    if status.success?
      puts "Converted #{input_file} to #{output_file}"
    else
      puts "Conversion of #{input_file} has error: #{error}"
    end
  end
end
