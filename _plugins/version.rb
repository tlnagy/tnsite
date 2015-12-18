require 'open3'
# injects versions of programs

module Jekyll
  module Version

    class Generator < Jekyll::Generator
        def generate(site)
            version = sh("jekyll", "--version")
            site.data["jekyll_ver"] = version.split(" ")[1]
            version = sh("pandoc", "--version")
            site.data["pandoc_ver"] = version.split(" ")[1]
            version = sh("ruby", "--version")
            parts = version.split(" ")
            site.data["ruby_ver"] = parts[1]
            site.data["os_ver"] = parts[-1][1...-1]
            # Generate pdf
            sh("pandoc", "cv.md", "-o", "assets/tamasnagy_cv.pdf")
        end
        
        def sh(*args)
            Open3.popen2e(*args) do |stdin, stdout_stderr, wait_thr|
          exit_status = wait_thr.value # wait for it...
          output = stdout_stderr.read
          output ? output.strip : nil
            end
        end
    end
  end
end