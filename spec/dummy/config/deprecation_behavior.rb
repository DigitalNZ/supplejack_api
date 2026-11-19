# frozen_string_literal: true

# Test-only deprecation behavior: raise when the deprecated call comes from engine code,
# warn on stderr when it comes from a third-party gem (the first non-Rails frame decides).
module DeprecationBehavior
  RAILS_GEM = %r{/(activesupport|activemodel|activerecord|actionpack|actionview|actionmailer|actioncable|
                   activejob|activestorage|actiontext|actionmailbox|railties|rails)-\d}x
  ENGINE_ROOT = File.expand_path('../../..', __dir__)

  def self.gem_origin?(frame)
    return false if frame.nil?

    bundle_path = Bundler.bundle_path.to_s
    gem_dirs = Gem.path + [bundle_path]
    frame.start_with?(*gem_dirs) || !frame.start_with?(ENGINE_ROOT)
  end

  def self.call(message, callstack, _deprecator = nil)
    origin = callstack.map(&:to_s).find { |frame| frame !~ RAILS_GEM }

    if gem_origin?(origin)
      warn "DEPRECATION (gem): #{message}\n  from #{origin}"
    else
      raise ActiveSupport::DeprecationException, message
    end
  end
end
