# encoding: utf-8

# This fixes the bug in:
# /paperclip-2.4.5/lib/paperclip.rb:102
#
# Prior to this patch no interpolations where actually executed
require 'paperclip'

module Paperclip
  class << self
    def run(cmd, arguments = "", local_options = {})
      if options[:image_magick_path]
        Paperclip.log("[DEPRECATION] :image_magick_path is deprecated and will be removed. Use :command_path instead")
      end
      command_path = options[:command_path] || options[:image_magick_path]
      Cocaine::CommandLine.path = ( Cocaine::CommandLine.path ? [Cocaine::CommandLine.path, command_path ].flatten : command_path )
      local_options = local_options.merge(:logger => logger) if logging? && (options[:log_command] || local_options[:log_command])
      # added argument to #run
      Cocaine::CommandLine.new(cmd, arguments, local_options).run(local_options)
    end
  end
end
