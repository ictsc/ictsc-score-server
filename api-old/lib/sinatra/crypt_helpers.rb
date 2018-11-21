require 'sinatra/base'

module Sinatra
  module CryptHelpers
    module_function

    def hash_password(key, salt = '')
      return nil unless key.is_a? String

      crypt_binname = case RUBY_PLATFORM
        when /darwin/;  'crypt_darwin_amd64'
        when /freebsd/; 'crypt_freebsd_amd64'
        when /linux/;   'crypt_linux_amd64'
      end

      path = File.expand_path("../../../ext/#{crypt_binname}", __FILE__)
      hash, status = Open3.capture2(path, key, salt)

      if status.exitstatus.zero?
        hash.strip
      else
        nil
      end
    end

    def compare_password(key, hash)
      salt_len = hash.index('$', 3)
      return false if salt_len.nil?
      salt = hash.slice(0, salt_len)

      return hash_password(key, salt) == hash
    end
  end

  helpers CryptHelpers
end
