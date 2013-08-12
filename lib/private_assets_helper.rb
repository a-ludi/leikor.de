module PrivateAssetsHelper
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Returns the absolute file path to a private file or directory
    # +source_string_or_array+ which is either a relative path name or an array of
    # such. If +ext+ is given it will be appended separated with a dot.
    def path_to_private(source_string_or_array, ext=nil)
      base_name = File.join(Rails.root, 'private', source_string_or_array)

      [base_name, ext].compact.join('.')
    end
  end
end
