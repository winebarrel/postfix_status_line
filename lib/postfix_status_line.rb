require 'postfix_status_line/version'
require 'postfix_status_line_core'

module PostfixStatusLine
  SHA_ALGORITHM = %w(1 224 256 384 512)

  def parse(str, options = {})
    mask = options.has_key?(:mask) ? options[:mask] : true
    hash = options[:hash]
    salt = options[:salt]
    parse_time = options[:parse_time]
    sha_algo = options[:sha_algorithm]
    PostfixStatusLine::Core.parse(str, mask, hash, salt, parse_time, sha_algo)
  end
  module_function :parse

  def parse_header_checks(str, options = {})
    mask = options.has_key?(:mask) ? options[:mask] : true
    hash = options[:hash]
    salt = options[:salt]
    parse_time = options[:parse_time]
    sha_algo = options[:sha_algorithm]
    PostfixStatusLine::Core.parse_header_checks(str, mask, hash, salt, parse_time, sha_algo)
  end
  module_function :parse_header_checks
end
