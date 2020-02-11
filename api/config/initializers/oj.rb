# frozen_string_literal: true

# https://github.com/ohler55/oj/blob/develop/pages/Rails.md
Oj.default_options = { mode: :compat }
Oj.optimize_rails

# /problems 1.2s -> 0.5s
# /answers  6.0s -> 4.5ms
