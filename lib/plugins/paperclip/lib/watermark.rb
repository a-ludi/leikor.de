module Paperclip
  # Handles watermarking images that are uploaded.
  class Watermark < Processor
    attr_accessor :watermark_geometry, :watermark, :visibility, :position,
                  :offset, :size, :randomize, :whiny, :format, :animated,
                  :current_format, :basename

    # List of formats that we need to preserve animation
    ANIMATED_FORMATS = %w(gif)
    # List of valid gravities (positions)
    # Used to format the numbers in :format
    OFFSET_FORMAT = '%+f,%+f'

    # Creates a Watermark object set to work on the +file+ given. It will
    # attempt to place a watermark over the image. The option +watermark+ may be
    # either a string or file describing the watermark or a hash of options. In
    # the former case defaults will be used for all other options.
    #
    # Options include:
    #
    #   +file+       - path to watermark file or File object (mandatory)
    #   +visibility+ - a percentage between 0 and 100 (Default: 10)
    #   +position+   - position of the watermark; one of +[:north_west, :north,
    #                  :north_east, :west, :center, :east, :south_west, :south,
    #                  :south_east]+ (Default: +:center+)
    #   +offset+     - an array of two numbers indicating the pixel shift
    #                   (Default: [0, 0])
    #   +size+       - a geometry string as defined by ImageMagick without the
    #                  offset part (Default: "")
    #   +randomize+  - radius of random perspective distortion of the watermark
    #                  in pixels (Default: 0)
    #
    # The unscoped options +whiny+, +format+, +animated+ and
    # +file_geometry_parser+ are interpreted like in Thumbnail.
    def initialize(file, options = {}, attachment = nil)
      super

      @file                = file
      @watermark = if options[:watermark].is_a? Hash
        options[:watermark][:file]
      else
        options[:watermark]
      end

      @watermark_geometry = (options[:file_geometry_parser] || Geometry).from_file(@watermark)
      @visibility         = options[:watermark][:visibility] || 10
      @position           = options[:watermark][:position] || :center
      @offset             = options[:watermark][:offset] || [0, 0]
      @size               = options[:watermark][:size] || ''
      @randomize          = options[:watermark][:randomize] || 0

      @whiny              = options.include?(:whiny) ? options[:whiny] : true
      @format             = options[:format]
      @animated           = options.include?(:animated) ? options[:animated] : true
      @current_format     = File.extname(@file.path)
      @basename           = File.basename(@file.path, @current_format)
    end

    # Performs the conversion of the +file+ into a thumbnail. Returns the Tempfile
    # that contains the new image.
    def make
      src = @file
      dst = Tempfile.new([@basename, @format ? ".#{@format}" : ''])
      dst.binmode

      begin
        watermark_file = File.open(watermark)

        parameters = []
        parameters << ":source"
        parameters << watermark_command
        parameters << ":dest"

        parameters = parameters.flatten.compact.join(" ").strip.squeeze(" ")

        success = Paperclip.run(
          "convert",
          parameters,
          :source => "#{File.expand_path(src.path)}#{'[0]' unless animated?}",
          :watermark => "#{File.expand_path(watermark_file)}",
          :dest => File.expand_path(dst.path)
        )
      rescue Cocaine::ExitStatusError => e
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}" if @whiny
      rescue Errno::ENOENT => e
        raise PaperclipError, "Could not open watermark #{watermark}" if @whiny
      rescue Cocaine::CommandNotFoundError => e
        raise Paperclip::CommandNotFoundError.new("Could not run the `convert` command. Please install ImageMagick.")
      end

      dst
    end

    # Returns the command ImageMagick's +convert+ needs to apply the watermark.
    def watermark_command
      command = []
      command << "-coalesce" if animated?
      command << "-gravity #{position}"
      command << "\\("
      command << ":watermark"
      command << "-geometry #{size}#{offset_string}"
      if randomize?
        command << "-virtual-pixel transparent"
        command << "+distort perspective '#{randomize_string}'"
      end
      command << "\\)"
      command << "-compose dissolve"
      command << "-define compose:args=#{visibility}"
      command << "-composite"
    end

    protected

    # Return true if the format is animated
    def animated?
      @animated && ANIMATED_FORMATS.include?(@current_format[1..-1]) && (ANIMATED_FORMATS.include?(@format.to_s) || @format.blank?)
    end

    # Return true if randomization should be performed
    def randomize?
      randomize and randomize > 0
    end

    # Returns the offset as understood by ImageMagick
    def offset_string
      OFFSET_FORMAT % offset
    end

    def randomize_string
      height = watermark_geometry.height
      width = watermark_geometry.width

      corners = [[0, 0], [0, height], [width, 0], [width, height]]
      corners.map! do |corner|
        x, y = corner
        "#{x},#{y} #{x + rand_offset},#{y + rand_offset}"
      end
      corners.join ' '
    end

    def rand_offset
      (rand * 2.0 - 1.0) * randomize
    end
  end
end
