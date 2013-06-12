
module HtmlToPdf

  # Modules are in fact, classes, so we reopen this module and add a few functions
  class << self

#-----------------------------------
# PDF GENERATION USING xhtml2pdf
#-----------------------------------

    # Generates temporal pdf file, returning the file name of the generated file
    def generate_pdf_string(input_html_string)
      tmp_base_file_name = "#{Rails.root}/tmp/tmpdoc_#{DateTime.now.to_i.to_s}"
      pdf_string = nil
      if generate_tmp_files(input_html_string, tmp_base_file_name)
        pdf_string = File.open("#{tmp_base_file_name}.pdf", 'r').read
        File.delete "#{tmp_base_file_name}.html" if File.exists? "#{tmp_base_file_name}.html"
        File.delete "#{tmp_base_file_name}.pdf" if File.exists? "#{tmp_base_file_name}.pdf"
      end
      pdf_string     
    end

    # Generates temporal pdf file, returning the file name of the generated file
    def generate_tmp_files(input_html_string, base_file_name)
      html_file = File.open("#{base_file_name}.html", "w") {|f| f.write(input_html_string) }
      pdf_command = "xhtml2pdf #{base_file_name}.html"
      ret =   %x[#{pdf_command}]  
      File.exists? "#{base_file_name}.pdf"
    end

#------------------------------------------------
# OLD PDF GENERATION METHODS (hpricot + prawn)
#   If PDf generation is going to work the same way, hpricot should be substituted by Nokogiri, and a recent version odf Prawn 
#------------------------------------------------

#require 'rubygems'
#require 'hpricot'
#require 'prawn'

#    def parse_font_metrics( pdf_doc, element, current_font_face, current_font_size, current_font_style )
#      # First, look for classic HTML attributes
#      face_attr = element.get_attribute('face')
#      if face_attr.nil? == false
#        faces = face_attr.split(",")
#        faces.each do |face|
#          face = translate_font(face)
#          begin
#            pdf_doc.font face.strip
#            current_font_face = face.strip
#            break
#          rescue Prawn::Errors::UnknownFont
#            current_font_face = "Times-Roman"
#          end
#        end
#      end
#      size_attr = element.get_attribute('size')
#      if size_attr.nil? == false && size_attr.to_i != 0
#        case size_attr.to_i
#        when 1
#          current_font_size = 6
#        when 2
#          current_font_size = 9
#        when 3
#          current_font_size = 12
#        end
#      end
#      # but override with STYLE
#      style_attr = element.get_attribute('style')
#      if style_attr.nil? == false
#        style_attr.strip.split(";").each do |attr|
#          name_and_value = attr.strip.split(":")
#          case name_and_value[0]
#          when 'font-size'
#            current_font_size = name_and_value[1].to_i
#          end
#        end
#      end
#      return current_font_face, current_font_size, current_font_style
#    end

#    def translate_fonts_table
#      { "Times New Roman" => "Times-Roman" }
#    end

#    def translate_font( fontname )
#      good_font = translate_fonts_table[ fontname ]
#      if good_font.nil?
#        return fontname
#      else
#        return good_font
#      end
#    end

#    def generate_pdf( pdf_doc, element, current_font_face, current_font_size, current_font_style)

#      return if (element.nil? || element.doctype?())
#      save_font_face = current_font_face
#      save_font_size = current_font_size
#      save_font_style = current_font_style
#      if element.doc?
#        element_name = ""
#      else
#        element_name = element.methods.include?("name") ? element.name.downcase : ""
#      end
#      
#      case element_name
#      when 'font'
#        current_font_face, current_font_size, current_font_style = parse_font_metrics( pdf_doc, element, current_font_face, current_font_size, current_font_style )
#      when 'i'
#        current_font_style = :italic
#      when 'b'
#        current_font_style = :bold
#      when 'u'
#        current_font_style = :bold_italic
#      end
#      if element.text?()
#        if element.inner_text != "\n" && element.inner_text != "\t"
#          pdf_doc.font current_font_face, :size => current_font_size, :style => current_font_style
#          pdf_doc.text element.inner_text
##          pdf_doc.draw_text element.inner_text, :at => [ pdf_doc.bounds.left, pdf_doc.bounds.top ]
#        end
#        return
#      end
#      unless element.children.nil?
#        element.children.each { |c|
#          generate_pdf( pdf_doc, c, current_font_face, current_font_size, current_font_style )
#        }
#      end
#      pdf_doc.font save_font_face, :size => save_font_size, :style => save_font_style
#    end

#    def html_file_to_pdf( html_file_name, pdf_file_name)
#      pdf_doc = Prawn::Document.new
#      html_doc = open( html_file_name ) { |f| Hpricot(f) }

#      generate_pdf( pdf_doc, html_doc, "Times-Roman", 11, nil )
#      pdf_doc.render_file( pdf_file_name )
#    end


#    def html_string_to_pdf( html_string, pdf_file_name)
#      pdf_doc = Prawn::Document.new(:bottom_margin => 0)
#      html_string.gsub!("<br />", "")
#      html_string.gsub!("<br/>", "")
#      html_string.gsub!("<br>", "")
#      html_doc = Hpricot("<div>#{ html_string }</div>")
#      
#      
#      safe_string = html_doc.search("p").map(&:innerHTML).join("\n\n")
#      pdf_doc.font "Times-Roman", :size => 11, :style => nil
#      
##FIXME: IMAGE IS HARD-CODED!!  
#      #safe_string = ''
#      pdf_doc.text("\n\n")
#      html_doc.search("p").each do |element|
#        imgs = element.search("a/img")
#        if imgs.any?
#          imgs.each{|img| pdf_doc.image "#{RAILS_ROOT}/public/images/video_snapshot.jpg", :height => 100, :position => :center}
#        elsif element.attributes["class"] == "right"
#          pdf_doc.text(element.innerHTML, :inline_format => true, :align => :right)
#        elsif element.attributes["class"] == "center"
#          pdf_doc.text(element.innerHTML, :inline_format => true, :align => :center)
#        else
#          pdf_doc.text(element.innerHTML, :inline_format => true)
#        end
#        pdf_doc.text("\n")
#      end
#      
#      #pdf_doc.text(safe_string, :inline_format => true)
#      #generate_pdf( pdf_doc, html_doc, "Times-Roman", 9, nil )
#      pdf_doc.render_file( pdf_file_name )
#    end


  end

end
