require_relative 'bundle'

class Xcode < Bundle
  attr_accessor :signed

  # Hardcoded paths in case mdfind is not working because Spotlight is disabled
  DEFAULT_XCODE_PATHS = [
    "/Applications/Xcode.app",
    "/Applications/Xcode-beta.app",
    "/Applications/Xcode-unsigned.app"
  ]

  XCODE_BUNDLE_IDENTIFIER = "com.apple.dt.Xcode"

  def self.find_xcodes
    output = `mdfind kMDItemCFBundleIdentifier = "#{XCODE_BUNDLE_IDENTIFIER}"`
    paths = output.lines + DEFAULT_XCODE_PATHS

    paths.map(&:strip).uniq.collect do |xcode_path|
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
    return false unless is_app && has_info

    bundle_identifier == XCODE_BUNDLE_IDENTIFIER
  end

  def signed?
    if signed.nil?
      self.signed = `codesign -dv "#{path}" 2>/dev/null` &&
                    $CHILD_STATUS.exitstatus == 0
    end

    signed
  end

  def restorable?
    binary_restorable? || xcodebuild_restorable?
  end

  def binary_restorable?
    File.exist?("#{binary_path}.signed")
  end

  def xcodebuild_restorable?
    File.exist?("#{xcodebuild_path}.signed")
  end

  def unsign_binary!
    unsign!(binary_path)
  end

  def unsign_xcodebuild!
    unsign!(xcodebuild_path)
  end

  def restore_binary!
    restore!(binary_path)
  end

  def restore_xcodebuild!
    restore!(xcodebuild_path)
  end

  def uuid
    defaults_read('DVTPlugInCompatibilityUUID')
  end

  def to_s
    unless signed.nil?
      codesign_status = signed ? ' [Signed]' : ' [Unsigned]'
    end

    "Xcode (#{version})#{codesign_status}: #{path}"
  end

  def detailed_description
    "Xcode (#{version}) [#{uuid}]: #{path}"
  end

  private

  def binary_path
    "#{path}/Contents/MacOS/Xcode"
  end

  def xcodebuild_path
    "#{path}/Contents/Developer/usr/bin/xcodebuild"
  end

  def unsign_path
    lib_path = File.expand_path(File.dirname(__FILE__))

    "#{lib_path}/bin/unsign"
  end

  def unsign!(target)
    unsigned_target = "#{target}.unsigned"
    signed_target = "#{target}.signed"

    CLI.chown_if_required(File.dirname(target)) do
      `#{unsign_path} "#{target}"` &&
        $CHILD_STATUS.exitstatus == 0
        File.exist?(unsigned_target) &&
        FileUtils.mv(target, signed_target) &&
        File.exist?(signed_target) &&
        FileUtils.mv(unsigned_target, target)
    end
  end

  def restore!(target)
    signed_target = "#{target}.signed"

    CLI.chown_if_required(File.dirname(target)) do
      File.exist?(signed_target) &&
        File.exist?(target) &&
        FileUtils.mv(signed_target, target)
    end
  end
end
