# frozen_string_literal: true

# https://techlife.cookpad.com/entry/a-guide-to-monkey-patchers
# 基本的にはrefineを使う

Dir[Rails.root.join('lib', 'monkey_patches', '**', '*.rb')]
  .sort
  .each {|file| require file }
