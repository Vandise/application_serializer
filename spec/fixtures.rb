require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Schema.define do
  self.verbose = false
  create_table :people, force: true do |t|
    t.string :name
    t.string :catch_phrase
    t.timestamps null: false
  end
end

class Person < ActiveRecord::Base; end;

class PersonSerializer < ApplicationSerializer::Base
  context :show do |serialize|
    serialize.attributes :id, :name, :catch_phrase
  end

  context :list do |serialize,scope|
    serialize.attribute :id, key: :key
    serialize.attribute :name, key: :value
  end

  context :byline do |serialize|
    serialize.attributes :byline
  end

  def byline
    "#{object.name} says '#{object.catch_phrase}'"
  end
end