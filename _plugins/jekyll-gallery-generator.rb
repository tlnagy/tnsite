require 'exifr'
require 'rmagick'
include Magick

include FileUtils

$image_extensions = [".png", ".jpg", ".jpeg", ".gif"]

module Jekyll
  class GalleryFile < StaticFile
    def write(dest)
      return false
    end
  end

  class ReadYamlPage < Page
    def read_yaml(base, name, opts = {})
      begin
        self.content = File.read(File.join(base, name), (site ? site.file_read_opts : {}).merge(opts))
        if content =~ /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
          self.content = $POSTMATCH
          self.data = SafeYAML.load($1)
        end
      rescue SyntaxError => e
        Jekyll.logger.warn "YAML Exception reading #{File.join(base, name)}: #{e.message}"
      rescue Exception => e
        Jekyll.logger.warn "Error reading file #{File.join(base, name)}: #{e.message}"
      end

      self.data ||= {}
    end
  end

  class GalleryIndex < ReadYamlPage
    def initialize(site, base, dir, galleries)
      @site = site
      @base = base
      @dir = dir.gsub("source/", "")
      @name = "index.html"
      config = site.config["gallery"] || {}

      self.process(@name)
      gallery_index = File.join(base, "_layouts", "gallery_index.html")
      unless File.exists?(gallery_index)
        gallery_index = File.join(File.dirname(__FILE__), "gallery_index.html")
      end
      self.read_yaml(File.dirname(gallery_index), File.basename(gallery_index))
      self.data["title"] = config["title"] || "Photos"
      self.data["galleries"] = []
      begin
        sort_field = config["sort_field"] || "date_time"
        galleries.sort! {|a,b| b.data[sort_field] <=> a.data[sort_field]}
      rescue Exception => e
        puts "Error sorting galleries: #{e}"
        puts e.backtrace
      end
      if config["sort_reverse"]
        galleries.reverse!
      end
      galleries.each {|gallery|
        unless gallery.hidden
          self.data["galleries"].push(gallery.data)
        end
      }
    end
  end

  class GalleryPage < ReadYamlPage
    attr_reader :hidden

    def initialize(site, base, dir, gallery_name)
      @site = site
      @base = base
      @dest_dir = dir.gsub("source/", "")
      @dir = @dest_dir
      @name = "index.html"
      @images = []
      @hidden = false

      config = site.config["gallery"] || {}
      gallery_config = {}
      best_image = nil
      max_size_x = 400
      max_size_y = 400
      symlink = config["symlink"] || false
      scale_method = config["scale_method"] || "fit"
      begin
        max_size_x = config["thumbnail_size"]["x"]
      rescue
      end
      begin
        max_size_y = config["thumbnail_size"]["y"]
      rescue
      end
      begin
        gallery_config = config["galleries"][gallery_name] || {}
      rescue
      end
      self.process(@name)
      gallery_page = File.join(base, "_layouts", "gallery_page.html")
      unless File.exists?(gallery_page)
        gallery_page = File.join(File.dirname(__FILE__), "gallery_page.html")
      end
      self.read_yaml(File.dirname(gallery_page), File.basename(gallery_page))
      self.data["gallery"] = gallery_name
      gallery_title_prefix = config["title_prefix"] || "Photos: "
      gallery_name = gallery_name.gsub("_", " ").gsub(/\w+/) {|word| word.capitalize}
      begin
        gallery_name = gallery_config["name"] || gallery_name
      rescue
      end
      self.data["name"] = gallery_name
      self.data["title"] = "#{gallery_title_prefix}#{gallery_name}"
      thumbs_dir = File.join(site.dest, @dest_dir, "thumbs")
      begin
        @hidden = gallery_config["hidden"] || false
      rescue
      end
      if @hidden
        self.data["sitemap"] = false
      end

      FileUtils.mkdir_p(thumbs_dir, :mode => 0755)
        
      
      Dir.foreach(dir) do |image|
        next if image.chars.first == "."
        next unless image.downcase().end_with?(*$image_extensions)
        best_image = image
        @site.static_files << GalleryFile.new(site, base, File.join(@dest_dir, "thumbs"), image)
        image_path = File.join(dir, image)
        
        data = {}
        data["image"] = image
        begin
          data["datetime"] = EXIFR::JPEG.new(image_path).date_time.to_i
        rescue Exception => e
          data["datetime"] = 0
          puts "Error getting date_time for #{image}: #{e}"
        end
        begin
            data["model"] = EXIFR::JPEG.new(image_path).model.strip
            data["exposure"] = EXIFR::JPEG.new(image_path).exposure_time.to_s
            data["fstop"] = "f"+EXIFR::JPEG.new(image_path).f_number.to_f.to_s
        rescue Exception => e
            data["model"] = "N/A"
            data["exposure"] = "1/inf"
            data["fstop"] = "f0.0"
        end
        @images.push(data)
          
        if symlink
          link_src = site.in_source_dir(image_path)
          link_dest = site.in_dest_dir(image_path)
          @site.static_files.delete_if { |sf|
            sf.relative_path == "/" + image_path
          }
          @site.static_files << GalleryFile.new(site, base, dir, image)
          if File.exists?(link_dest) or File.symlink?(link_dest)
            if not File.symlink?(link_dest)
              puts "#{link_dest} exists but is not a symlink. Deleting."
              File.delete(link_dest)
            elsif File.readlink(link_dest) != link_src
              puts "#{link_dest} points to the wrong file. Deleting."
              File.delete(link_dest)
            end
          end
          if not File.exists?(link_dest) and not File.symlink?(link_dest)
            puts "Symlinking #{link_src} -> #{link_dest}"
            File.symlink(link_src, link_dest)
          end
        end
        thumb_path = File.join(thumbs_dir, image)
        if File.file?(thumb_path) == false or File.mtime(image_path) > File.mtime(thumb_path)
          begin
            m_image = ImageList.new(image_path)
            m_image.auto_orient!
            m_image.send("resize_to_#{scale_method}!", max_size_x, max_size_y)
            puts "Writing thumbnail to #{thumb_path}"
            m_image.write(thumb_path)
          rescue e
            puts "Error generating thumbnail for #{image_path}: #{e}"
            puts e.backtrace
          end
          GC.start
        end
      end

      begin
        sort_field = config["sort_photos"] || "date_time"
        @images = @images.sort_by { |data| data[:image] }
        if gallery_config["sort_reverse"]
          @images.reverse!
        end
      rescue Exception => e
        puts "Error sorting images in gallery #{gallery_name}: #{e}"
        puts e.backtrace
      end

      site.static_files = @site.static_files
      self.data["images"] = @images
      self.data["best_image"] = gallery_config["best_image"] || best_image
      best_image_path = File.join(dir, best_image)
      begin
        self.data["date_time"] = EXIFR::JPEG.new(best_image_path).date_time.to_i
      rescue Exception => e
        self.data["date_time"] = 0
        puts "Error getting date_time for #{best_image_path}: #{e}"
      end
    end
  end

  class GalleryGenerator < Generator
    safe true

    def generate(site)
      config = site.config["gallery"] || {}
      dir = config["dir"] || "photos"
      Dir.mkdir(dir) unless File.exists?(dir)
      galleries = []
      original_dir = Dir.getwd
      Dir.chdir(site.source)
      begin
        Dir.foreach(dir) do |gallery_dir|
          gallery_path = File.join(dir, gallery_dir)
          if File.directory?(gallery_path) and gallery_dir.chars.first != "."
            gallery = GalleryPage.new(site, site.source, gallery_path, gallery_dir)
            gallery.render(site.layouts, site.site_payload)
            gallery.write(site.dest)
            site.pages << gallery
            galleries << gallery
          end
        end
      rescue Exception => e
        puts "Error generating galleries: #{e}"
        puts e.backtrace
      end
      Dir.chdir(original_dir)

      gallery_index = GalleryIndex.new(site, site.source, dir, galleries)
      gallery_index.render(site.layouts, site.site_payload)
      gallery_index.write(site.dest)
      site.pages << gallery_index
    end
  end
end
