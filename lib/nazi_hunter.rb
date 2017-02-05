library_files = File.join(File.dirname(__FILE__),File.basename(__FILE__,".rb"),"*.rb")
Dir.glob(library_files) { |file|  require_relative file }

module NaziHunter
end
