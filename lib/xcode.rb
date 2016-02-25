require_relative 'bundle'

class Xcode < Bundle
  def self.find_xcodes
    output = `mdfind kMDItemCFBundleIdentifier = "com.apple.dt.Xcode"`
    output.lines.collect do |xcode_path|
      Xcode.from_bundle(xcode_path)
    end.compact.keep_if(&:valid?)
  end

  def self.from_bundle(path)
    xcode = new(path)
    xcode.valid? ? xcode : nil
  end

  def valid?
    is_app = path.end_with?('.app')
    has_info = File.exist?(info_path)

    is_app && has_info
  end

  def uuid
    defaults_read('DVTPlugInCompatibilityUUID')
  end

  def to_s
    "Xcode (#{version}) [#{uuid}]: #{path}"
  end
end
