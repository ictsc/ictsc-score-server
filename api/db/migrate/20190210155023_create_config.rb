class CreateConfig < ActiveRecord::Migration[5.2]
  def change
    create_table 'configs' do |t|
      t.string     'key',        null:   false
      t.string     'value',      null:   false, limit: 4095
      t.integer    'value_type', null:   false
      t.timestamps               null:   false
      t.index      'key',        unique: true
    end
  end
end
