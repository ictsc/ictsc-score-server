# frozen_string_literal: true

namespace :factory_bot do # rubocop:disable Metrics/BlockLength
  # schemaからfactoryのベースを作成する
  desc 'generate factory from ActiveRecord'

  def gen_block_body(column_type) # rubocop:disable Metrics/CyclomaticComplexity
    case column_type
    when :integer
      'n'
    when :boolean
      'n.odd?'
    when :string
      '"%<name>s #{n}"' # rubocop:disable Lint/InterpolationCheck
    when :uuid
      SecureRandom.uuid
    when :json
      '""'
    when :datetime
      # モックやスタブでTime.currentが固定されているとunique制約に引っかかる
      'Time.current + n.second'
    when /range\z/
      # int4range, datarange, tsrange, tstzrange, etc...
      '""'
    else
      pp column
      raise
    end
  end

  def gen_sequence(column)
    template = '    sequence(:%<name>s) {|n| %<block>s } # type: %<type>p, null: %<null>p'
    template += ', default: %<default>p' if column[:default]
    template % column.merge(block: gen_block_body(column[:type]))
  end

  def gen_association(column)
    # a[:options] = a[:factory].nil? ? '' : ", factory: #{a[:factory]}"
    options = ", factory: :#{column[:factory]}" unless column[:factory].nil?
    '    association :%<name>s%<options>s # optional: %<optional>p' % column.merge(options: options)
  end

  task :from, [:model_name] => :environment do |_task, args| # rubocop:disable Metrics/BlockLength
    model_name = args[:model_name].camelize
    model = model_name.constantize
    filepath = Rails.root.join("spec/factories/#{model_name.underscore}.rb")

    return if File.exist?(filepath)

    columns = model
      .columns
      .reject {|c| c.name.end_with?('_id') || model.primary_key == c.name }
      .map {|a| { name: a.name, type: a.sql_type_metadata.type, null: a.null, default: (a.default || a.default_function) } }

    reflections = model
      .reflections
      .map {|(_, a)| { name: a.name, factory: a.options[:class_name]&.underscore, optional: a.options[:optional] } }

    fields = columns.map(&method(:gen_sequence)) + reflections.map(&method(:gen_association))

    template = <<~'EOS'
      # frozen_string_literal: true

      FactoryBot.define do
        factory :%<model_name>s do
      %<fields>s
        end
      end
    EOS

    text = template % { model_name: model_name.underscore, fields: fields.join("\n") }
    puts text
    File.write(filepath, text)
  end
end
