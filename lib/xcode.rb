require_relative 'bundle'

class Xcode < Bundle
  attr_accessor :signed

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

  def signed?
    if signed.nil?
      self.signed = `codesign -dv "#{path}" 2>/dev/null` &&
                    $CHILD_STATUS.exitstatus == 0
    end

    signed
  end

  def unsign!
    `#{unsign_path} "#{binary_path}"` &&
      $CHILD_STATUS.exitstatus == 0 &&
      File.exist?(unsigned_binary_path) &&
      FileUtils.mv(unsigned_binary_path, binary_path)
  end

  def uuid
    defaults_read('DVTPlugInCompatibilityUUID')
  end

  def to_s
    unless signed.nil?
      codesign_status = signed ? '[Signed]' : '[Unsigned]'
    end

    "Xcode (#{version}) [#{uuid}]#{codesign_status}: #{path}"
  end

  private

  def binary_path
    "#{path}/Contents/MacOS/Xcode"
  end

  def unsigned_binary_path
    "#{binary_path}.unsigned"
  end

  def unsign_path
    lib_path = File.expand_path(File.dirname(__FILE__))

    "#{lib_path}/bin/unsign"
  end
end
